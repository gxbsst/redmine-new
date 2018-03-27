module RedmineCrm
  module FormTagHelper
    def select2_tag(name, option_tags = nil, options = {})
      id = sanitize_to_id(name)
      url = options[:url].to_s
      data = options[:data] || []
      placeholder = options[:placeholder] || 'Select ...'

      data_source =
        if url.empty?
          "data: #{data.to_json}"
        else
          "ajax: {
               url: '#{url}',
               dataType: 'json',
               delay: 250,
               data: function (params) {
                   return { q: params.term };
               },
               processResults: function (data, params) {
                   return { results: data };
               },
               cache: true
           }"
        end

      content_for(:header_tags) { select2_assets }
      result = select_tag(name, option_tags, options)
      result << javascript_tag(<<-JS)
        $(function () {
            $('select#' + '#{id}').select2({
                #{data_source},
                tags: #{options[:tags] || false},
                placeholder: '#{placeholder}'
            });
        });
      JS
    end
  end
end
