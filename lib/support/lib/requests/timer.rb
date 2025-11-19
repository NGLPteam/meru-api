# frozen_string_literal: true

module Support
  module Requests
    class Timer < Support::FlexibleStruct
      extend ActiveModel::Callbacks

      attribute :query, Support::Types::Coercible::String
      attribute :operation_name, Support::Types::String.optional
      attribute :variables, Support::Types::Hash.fallback { {} }

      define_model_callbacks :measure

      around_measure :record_duration!

      # @return [Integer]
      attr_reader :duration

      # @return [String]
      attr_reader :request_id

      # @return [::RequestQuery]
      attr_reader :request_query

      delegate :id, to: :request_query, prefix: true

      # @return [::RequestTiming]
      attr_reader :request_timing

      # @return [void]
      def measure!
        @request_id = Support::Requests::Current.request_id || SecureRandom.uuid

        @request_query ||= load_request_query!

        @duration = 0.0

        update_current_request!

        run_callbacks :measure do
          yield
        end
      ensure
        store_steps!

        log_request!
      end

      private

      # @return [RequestQuery]
      def load_request_query!
        ::RequestQuery.where(query:).first_or_create! do |rq|
          rq.operation_name = operation_name
        end
      end

      # @return [void]
      def log_request!
        milliseconds = (duration * 1000).round(2)

        Rails.logger.info("[graphql][#{request_query.kind}] Operation=#{request_query.operation_name || 'N/A'} Duration=#{milliseconds}ms")
      end

      # @return [void]
      def record_duration!
        @duration = AbsoluteTime.realtime do
          yield
        end

        @request_query.request_timings.create(variables:, duration:, request_id:)
      end

      # @return [void]
      def store_steps!
        base_tuple = { request_query_id:, request_id:, created_at: Time.current, updated_at: Time.current }

        tuples = Support::Requests::Current.graphql_steps.map do |step|
          base_tuple.merge(step)
        end

        # :nocov:
        return if tuples.empty?
        # :nocov:

        ::RequestStep.insert_all(tuples, returning: nil)
      end

      # @return [void]
      def update_current_request!
        Support::Requests::Current.graphql_kind = request_query.kind
        Support::Requests::Current.graphql_operation_name = request_query.operation_name
      end

      class << self
        def measure!(**kwargs, &)
          new(**kwargs).measure!(&)
        end
      end
    end
  end
end
