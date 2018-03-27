require 'redmine_crm/helpers/vote_helper'

module RedmineCrm
  module ActsAsVotable
    module Votable
      include ActsAsVotable::Helpers::Words

      def self.included(base)
        # allow the user to define these himself
        aliases = {

          :vote_up => [
            :up_by, :upvote_by, :like_by, :liked_by,
            :up_from, :upvote_from, :upvote_by, :like_from, :liked_from, :vote_from
          ],

          :vote_down => [
            :down_by, :downvote_by, :dislike_by, :disliked_by,
            :down_from, :downvote_from, :downvote_by, :dislike_by, :disliked_by
          ],

          :get_up_votes => [
            :get_true_votes, :get_ups, :get_upvotes, :get_likes, :get_positives, :get_for_votes,
          ],

          :get_down_votes => [
            :get_false_votes, :get_downs, :get_downvotes, :get_dislikes, :get_negatives
          ],
          :unvote_by => [
            :unvote_up, :unvote_down, :unliked_by, :undisliked_by
          ]
        }

        base.class_eval do
          has_many :votes_for, :class_name => 'RedmineCrm::ActsAsVotable::Vote', :as => :votable, :dependent => :destroy do
            def voters
              includes(:voter).map(&:voter)
            end
          end

          aliases.each do |method, links|
            links.each do |new_method|
              alias_method(new_method, method)
            end
          end
        end
      end

      attr_accessor :vote_registered

      def vote_registered?
        self.vote_registered
      end

      def default_conditions
        {
          :votable_id => self.id,
          :votable_type => self.class.base_class.name.to_s
        }
      end

      # voting
      def vote_by(args = {})
        options = {
          :vote => true,
          :vote_scope => nil
        }.merge(args)

        self.vote_registered = false

        return false if options[:voter].nil?

        # find the vote
        vote_conditions = { :vote_scope => options[:vote_scope], :voter_type => options[:voter].class.base_class.name }
        vote_conditions.merge!(options[:vote_by_ip] ? { :vote_ip => options[:vote_ip] } : { :voter_id => options[:voter].id} )
        votes_for = find_votes_for(vote_conditions)

        if votes_for.count == 0 || options[:duplicate]
          # this voter has never voted
          vote_params = { :votable => self, :voter => options[:voter], :vote_scope => options[:vote_scope] }
          vote_params[:vote_ip] = options[:vote_ip] if options[:vote_ip]
          vote = RedmineCrm::ActsAsVotable::Vote.new(vote_params)
        else
          # this voter is potentially changing his vote
          vote = votes_for.last
        end

        last_update = vote.updated_at

        vote.vote_flag = votable_words.meaning_of(options[:vote])

        # Allowing for a vote_weight to be associated with every vote. Could change with every voter object
        vote.vote_weight = (options[:vote_weight].to_i if options[:vote_weight].present?) || 1

        if vote.save
          self.vote_registered = true if last_update != vote.updated_at
          update_cached_votes options[:vote_scope]
          return vote
        else
          self.vote_registered = false
          return false
        end
      end

      def unvote(args = {})
        return false if (!args[:vote_by_ip] && args[:voter].nil?) || (args[:vote_by_ip] && args[:vote_ip].nil?)
        vote_conditions = { :vote_scope => args[:vote_scope], :voter_type => args[:voter].class.base_class.name }
        vote_conditions.merge!(args[:vote_by_ip] ? { :vote_ip => args[:vote_ip] } : { :voter_id => args[:voter].id})
        votes_for = find_votes_for(vote_conditions)

        return true if votes_for.empty?
        votes_for.each(&:destroy)
        update_cached_votes args[:vote_scope]
        self.vote_registered = false if votes_for.count == 0
        true
      end

      def vote_up(voter, options={})
        self.vote_by :voter => voter, :vote => true,
                     :vote_scope => options[:vote_scope], :vote_weight => options[:vote_weight], :vote_ip => options[:vote_ip],
                     :vote_by_ip => options[:vote_by_ip]
      end

      def vote_down(voter, options={})
        self.vote_by :voter => voter, :vote => false,
                     :vote_scope => options[:vote_scope], :vote_weight => options[:vote_weight], :vote_ip => options[:vote_ip],
                     :vote_by_ip => options[:vote_by_ip]
      end

      def unvote_by(voter, options = {})
        # Does not need vote_weight since the votes_for are anyway getting destroyed
        self.unvote :voter => voter, :vote_scope => options[:vote_scope], :vote_ip => options[:vote_ip],
                    :vote_by_ip => options[:vote_by_ip]
      end

      def scope_cache_field(field, vote_scope)
        return field if vote_scope.nil?

        case field
        when :cached_votes_total=
          "cached_scoped_#{vote_scope}_votes_total="
        when :cached_votes_total
          "cached_scoped_#{vote_scope}_votes_total"
        when :cached_votes_up=
          "cached_scoped_#{vote_scope}_votes_up="
        when :cached_votes_up
          "cached_scoped_#{vote_scope}_votes_up"
        when :cached_votes_down=
          "cached_scoped_#{vote_scope}_votes_down="
        when :cached_votes_down
          "cached_scoped_#{vote_scope}_votes_down"
        when :cached_votes_score=
          "cached_scoped_#{vote_scope}_votes_score="
        when :cached_votes_score
          "cached_scoped_#{vote_scope}_votes_score"
        when :cached_weighted_total
          "cached_weighted_#{vote_scope}_total"
        when :cached_weighted_total=
          "cached_weighted_#{vote_scope}_total="
        when :cached_weighted_score
          "cached_weighted_#{vote_scope}_score"
        when :cached_weighted_score=
          "cached_weighted_#{vote_scope}_score="
        when :cached_weighted_average
          "cached_weighted_#{vote_scope}_average"
        when :cached_weighted_average=
          "cached_weighted_#{vote_scope}_average="
        end
      end

      # caching
      def update_cached_votes(vote_scope = nil)
        updates = {}

        if self.respond_to?(:cached_votes_total=)
          updates[:cached_votes_total] = count_votes_total(true)
        end

        if self.respond_to?(:cached_votes_up=)
          updates[:cached_votes_up] = count_votes_up(true)
        end

        if self.respond_to?(:cached_votes_down=)
          updates[:cached_votes_down] = count_votes_down(true)
        end

        if self.respond_to?(:cached_votes_score=)
          updates[:cached_votes_score] = (
            (updates[:cached_votes_up] || count_votes_up(true)) -
            (updates[:cached_votes_down] || count_votes_down(true))
          )
        end

        if self.respond_to?(:cached_weighted_total=)
          updates[:cached_weighted_total] = weighted_total(true)
        end

        if self.respond_to?(:cached_weighted_score=)
          updates[:cached_weighted_score] = weighted_score(true)
        end

        if self.respond_to?(:cached_weighted_average=)
          updates[:cached_weighted_average] = weighted_average(true)
        end

        if vote_scope
          if self.respond_to?(scope_cache_field :cached_votes_total=, vote_scope)
            updates[scope_cache_field :cached_votes_total, vote_scope] = count_votes_total(true, vote_scope)
          end

          if self.respond_to?(scope_cache_field :cached_votes_up=, vote_scope)
            updates[scope_cache_field :cached_votes_up, vote_scope] = count_votes_up(true, vote_scope)
          end

          if self.respond_to?(scope_cache_field :cached_votes_down=, vote_scope)
            updates[scope_cache_field :cached_votes_down, vote_scope] = count_votes_down(true, vote_scope)
          end

          if self.respond_to?(scope_cache_field :cached_weighted_total=, vote_scope)
            updates[scope_cache_field :cached_weighted_total, vote_scope] = weighted_total(true, vote_scope)
          end

          if self.respond_to?(scope_cache_field :cached_weighted_score=, vote_scope)
            updates[scope_cache_field :cached_weighted_score, vote_scope] = weighted_score(true, vote_scope)
          end

          if self.respond_to?(scope_cache_field :cached_votes_score=, vote_scope)
            updates[scope_cache_field :cached_votes_score, vote_scope] = (
              (updates[scope_cache_field :cached_votes_up, vote_scope] || count_votes_up(true, vote_scope)) -
              (updates[scope_cache_field :cached_votes_down, vote_scope] || count_votes_down(true, vote_scope))
            )
          end

          if self.respond_to?(scope_cache_field :cached_weighted_average=, vote_scope)
            updates[scope_cache_field :cached_weighted_average, vote_scope] = weighted_average(true, vote_scope)
          end
        end
        self.record_timestamps = false
        if (::ActiveRecord::VERSION::MAJOR == 3) && (::ActiveRecord::VERSION::MINOR != 0)
          self.update_attributes(updates, :without_protection => true) if !updates.empty?
        else
          self.update_attributes(updates) if !updates.empty?
        end
      end

      # results
      def find_votes_for(extra_conditions = {})
        votes_for.where(extra_conditions)
      end

      def get_up_votes(options = {})
        vote_scope_hash = scope_or_empty_hash(options[:vote_scope])
        find_votes_for({:vote_flag => true}.merge(vote_scope_hash))
      end

      def get_down_votes(options = {})
        vote_scope_hash = scope_or_empty_hash(options[:vote_scope])
        find_votes_for({ :vote_flag => false }.merge(vote_scope_hash))
      end

      # counting
      def count_votes_total(skip_cache = false, vote_scope = nil)
        if !skip_cache && self.respond_to?(scope_cache_field :cached_votes_total, vote_scope)
          return self.send(scope_cache_field :cached_votes_total, vote_scope)
        end
        find_votes_for(scope_or_empty_hash(vote_scope)).count
      end

      def count_votes_up(skip_cache = false, vote_scope = nil)
        if !skip_cache && self.respond_to?(scope_cache_field :cached_votes_up, vote_scope)
          return self.send(scope_cache_field :cached_votes_up, vote_scope)
        end
        get_up_votes(:vote_scope => vote_scope).count
      end

      def count_votes_down(skip_cache = false, vote_scope = nil)
        if !skip_cache && self.respond_to?(scope_cache_field :cached_votes_down, vote_scope)
          return self.send(scope_cache_field :cached_votes_down, vote_scope)
        end
        get_down_votes(:vote_scope => vote_scope).count
      end

      def weighted_total(skip_cache = false, vote_scope = nil)
        if !skip_cache && self.respond_to?(scope_cache_field :cached_weighted_total, vote_scope)
          return self.send(scope_cache_field :cached_weighted_total, vote_scope)
        end
        ups = get_up_votes(:vote_scope => vote_scope).sum(:vote_weight)
        downs = get_down_votes(:vote_scope => vote_scope).sum(:vote_weight)
        ups + downs
      end

      def weighted_score(skip_cache = false, vote_scope = nil)
        if !skip_cache && self.respond_to?(scope_cache_field :cached_weighted_score, vote_scope)
          return self.send(scope_cache_field :cached_weighted_score, vote_scope)
        end
        ups = get_up_votes(:vote_scope => vote_scope).sum(:vote_weight)
        downs = get_down_votes(:vote_scope => vote_scope).sum(:vote_weight)
        ups - downs
      end

      def weighted_average(skip_cache = false, vote_scope = nil)
        if !skip_cache && self.respond_to?(scope_cache_field :cached_weighted_average, vote_scope)
          return self.send(scope_cache_field :cached_weighted_average, vote_scope)
        end

        count = count_votes_total(skip_cache, vote_scope).to_i
        if count > 0
          weighted_score(skip_cache, vote_scope).to_f / count
        else
          0.0
        end
      end

      # voters
      def voted_on_by?(voter)
        votes = find_votes_for :voter_id => voter.id, :voter_type => voter.class.base_class.name
        votes.count > 0
      end

      private

      def scope_or_empty_hash(vote_scope)
        vote_scope ? { :vote_scope => vote_scope } : {}
      end
    end
  end
end
