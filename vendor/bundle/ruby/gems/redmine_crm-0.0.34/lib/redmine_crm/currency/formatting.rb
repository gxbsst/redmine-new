# encoding: UTF-8
module RedmineCrm
  class Currency
    module Formatting
      def self.included(base)
        [
          [:thousands_separator, :delimiter, ","],
          [:decimal_mark, :separator, "."]
        ].each do |method, name, character|
          define_i18n_method(method, name, character)
        end
      end

      def self.define_i18n_method(method, name, character)
        define_method(method) do
          if self.class.use_i18n
            begin
              I18n.t name, :scope => "number.currency.format", :raise => true
            rescue I18n::MissingTranslationData
              I18n.t name, :scope =>"number.format", :default => (currency.send(method) || character)
            end
          else
            currency.send(method) || character
          end
        end
        alias_method name, method
      end

      def format(value, currency, *rules)
        # support for old format parameters
        rules = normalize_formatting_rules(rules)
        if currency
          rules = self.localize_formatting_rules(rules, currency)
          rules = self.translate_formatting_rules(rules, currency.code) if rules[:translate]
          rules[:decimal_mark] = currency.decimal_mark if rules[:decimal_mark].nil?
          rules[:decimal_places] = currency.decimal_places
          rules[:subunit_to_unit] = currency.subunit_to_unit
          rules[:thousands_separator] = currency.thousands_separator if rules[:thousands_separator].nil?
        end
        rules = Currency.default_formatting_rules.merge(rules){|key, v1, v2| v2.nil? ? v1 : v2}

        # if fractional == 0
        if rules[:display_free].respond_to?(:to_str)
          return rules[:display_free]
        elsif rules[:display_free]
          return "free"
        end
        # end

        symbol_value = currency.try(:symbol) || ""

        formatted = value.abs.to_s

        # if rules[:rounded_infinite_precision]
        if currency
          formatted.gsub!(/#{rules[:decimal_mark]}/, '.') unless '.' == rules[:decimal_mark]
          formatted = ((BigDecimal(formatted) * currency.subunit_to_unit).round / BigDecimal(currency.subunit_to_unit.to_s)).to_s("F")
          formatted.gsub!(/\..*/) do |decimal_part|
            decimal_part << '0' while decimal_part.length < (currency.decimal_places + 1)
            decimal_part
          end
          formatted.gsub!(/\./, rules[:decimal_mark]) unless '.' == rules[:decimal_mark]
        end

        sign = value < 0 ? '-' : ''

        if rules[:no_cents] || (rules[:no_cents_if_whole] && cents % currency.subunit_to_unit == 0)
          formatted = "#{formatted.to_i}"
        end

        # thousands_separator_value = currency.thousands_separator
        # Determine thousands_separator
        if rules.has_key?(:thousands_separator)
          thousands_separator_value = rules[:thousands_separator] || ''
        end
        decimal_mark = rules[:decimal_mark]
        # Apply thousands_separator
        formatted.gsub!(regexp_format(formatted, rules, decimal_mark, symbol_value),
                        "\\1#{thousands_separator_value}")

        symbol_position = symbol_position_from(rules, currency) if currency

        if rules[:sign_positive] == true && (value >= 0)
          sign = '+'
        end

        if rules[:sign_before_symbol] == true
          sign_before = sign
          sign = ''
        end

        if symbol_value && !symbol_value.empty?
          symbol_value = "<span class=\"currency_symbol\">#{symbol_value}</span>" if rules[:html_wrap_symbol]
          formatted = if symbol_position == :before
            symbol_space = rules[:symbol_before_without_space] === false ? " " : ""
            "#{sign_before}#{symbol_value}#{symbol_space}#{sign}#{formatted}"
          else
            symbol_space = rules[:symbol_after_without_space] ? "" : " "
            "#{sign_before}#{sign}#{formatted}#{symbol_space}#{symbol_value}"
          end
        else
          formatted="#{sign_before}#{sign}#{formatted}"
        end

        # apply_decimal_mark_from_rules(formatted, rules)

        if rules[:with_currency]
          formatted << " "
          formatted << '<span class="currency">' if rules[:html]
          formatted << currency.to_s
          formatted << '</span>' if rules[:html]
        end
        formatted
      end

      def default_formatting_rules
        {
          :decimal_mark =>".",
          :thousands_separator => ",",
          :subunit_to_unit => 100
        }
      end

      def regexp_format(formatted, rules, decimal_mark, symbol_value)
        regexp_decimal = Regexp.escape(decimal_mark)
        if rules[:south_asian_number_formatting]
          /(\d+?)(?=(\d\d)+(\d)(?:\.))/
        else
          # Symbols may contain decimal marks (E.g "դր.")
          if formatted.sub(symbol_value.to_s, "") =~ /#{regexp_decimal}/
            /(\d)(?=(?:\d{3})+(?:#{regexp_decimal}))/
          else
            /(\d)(?=(?:\d{3})+(?:[^\d]{1}|$))/
          end
        end
      end

      def translate_formatting_rules(rules, iso_code)
        begin
          rules[:symbol] = I18n.t iso_code, :scope => "number.currency.symbol", :raise => true
        rescue I18n::MissingTranslationData
          # Do nothing
        end
        rules
      end

      def localize_formatting_rules(rules, currency)
        if currency.iso_code == "JPY" && I18n.locale == :ja
          rules[:symbol] = "円" unless rules[:symbol] == false
          rules[:symbol_position] = :after
          rules[:symbol_after_without_space] = true
        elsif currency.iso_code == "CHF"
          rules[:symbol_before_without_space] = false
        end
        rules
      end

      def symbol_value_from(rules)
        if rules.has_key?(:symbol)
          if rules[:symbol] === true
            symbol
          elsif rules[:symbol]
            rules[:symbol]
          else
            ""
          end
        elsif rules[:html]
          currency.html_entity == '' ? currency.symbol : currency.html_entity
        elsif rules[:disambiguate] and currency.disambiguate_symbol
          currency.disambiguate_symbol
        else
          symbol
        end
      end

      def symbol_position_from(rules, currency)
        if rules.has_key?(:symbol_position)
          if [:before, :after].include?(rules[:symbol_position])
            return rules[:symbol_position]
          else
            raise ArgumentError, ":symbol_position must be ':before' or ':after'"
          end
        elsif currency.symbol_first?
          :before
        else
          :after
        end
      end

      private

      # Cleans up formatting rules.
      #
      # @param [Hash] rules
      #
      # @return [Hash]
      def normalize_formatting_rules(rules)
        if rules.size == 0
          rules = {}
        elsif rules.size == 1
          rules = rules.pop
          rules = { rules => true } if rules.is_a?(Symbol)
        end
        rules[:decimal_mark] = rules[:separator] || rules[:decimal_mark]
        rules[:thousands_separator] = rules[:delimiter] || rules[:thousands_separator]
        rules
      end

      # Applies decimal mark from rules to formatted
      #
      # @param [String] formatted
      # @param [Hash]   rules
      def apply_decimal_mark_from_rules(formatted, rules)
        if rules.has_key?(:decimal_mark) && rules[:decimal_mark]
          # && rules[:decimal_mark] != decimal_mark

          regexp_decimal = Regexp.escape(rules[:decimal_mark])
          formatted.sub!(/(.*)(#{regexp_decimal})(.*)\Z/,
                         "\\1#{rules[:decimal_mark]}\\3")
        end
      end
    end
  end
end
