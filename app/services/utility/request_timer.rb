# frozen_string_literal: true

module Utility
  class RequestTimer < Support::FlexibleStruct
    extend ActiveModel::Callbacks

    attribute :query, Support::Types::Coercible::String
    attribute :operation_name, Support::Types::String.optional
    attribute :variables, Support::Types::Hash.fallback { {} }

    define_model_callbacks :measure

    around_measure :record_duration!

    # @return [Integer]
    attr_reader :duration

    # @return [RequestQuery]
    attr_reader :request_query

    # @return [RequestTiming]
    attr_reader :request_timing

    # @return [void]
    def measure!
      @request_query ||= load_request_query!

      run_callbacks :measure do
        yield
      end
    end

    private

    # @return [RequestQuery]
    def load_request_query!
      RequestQuery.where(query:).first_or_create! do |rq|
        rq.operation_name = operation_name
      end
    end

    # @return [void]
    def record_duration!
      @duration = AbsoluteTime.realtime do
        yield
      end

      @request_query.request_timings.create(variables:, duration:)
    end

    class << self
      def measure!(**kwargs, &)
        new(**kwargs).measure!(&)
      end
    end
  end
end
