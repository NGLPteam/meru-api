# frozen_string_literal: true

module System
  # A service that checks a number of counts and other cached values across the Meru system
  # to ensure things are up to date. It is intended to be run very frequently as a periodic
  # background job, so individual checks should be fast and idempotent.
  #
  # @see System::Check
  class Checker < Support::HookBased::Actor
    standard_execution!

    # @return [Hash{String => Float}]
    attr_reader :timings

    # @return [Dry::Monads::Result]
    def call
      run_callbacks :execute do
        yield prepare!

        yield check_entities!

        yield check_orderings!

        yield check_contributors!
      end

      Success timings
    end

    wrapped_hook! def prepare
      @timings = {}

      super
    end

    wrapped_hook! def check_entities
      yield call_and_time_operation("entity_visibilities.populate")

      yield call_and_time_operation("entity_visibilities.check")

      yield call_and_time_operation("entities.audit_hierarchies")

      super
    end

    wrapped_hook! def check_orderings
      yield call_and_time_operation("schemas.orderings.stats.calculate_all")

      super
    end

    wrapped_hook! def check_contributors
      yield call_and_time_operation("contributors.audit_contribution_counts")

      super
    end

    private

    # @param [String] name
    # @return [Dry::Monads::Result]
    def call_and_time_operation(name)
      result = nil

      @timings[name] = AbsoluteTime.realtime do
        result = call_operation(name)
      end

      return result
    end
  end
end
