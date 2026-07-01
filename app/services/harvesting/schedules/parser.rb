# frozen_string_literal: true

module Harvesting
  module Schedules
    # @see Harvesting::Schedules::Parse
    class Parser < Support::HookBased::Actor
      include Dry::Effects::Handler.Interrupt(:halt, as: :catch_halt)
      include Dry::Effects.Interrupt(:halt)

      include Dry::Initializer[undefined: false].define -> do
        param :frequency_expression, Harvesting::Schedules::Types::FrequencyExpression
      end

      MANUALLY = /\A\s*manual(?:ly)?\s*\z/i

      MIN_FREQUENCY = 4.hours

      standard_execution!

      # @return [<Symbol>]
      attr_reader :errors

      # @return [ActiveSupport::Duration, nil]
      attr_reader :frequency

      # @return [Harvesting::Schedules::Types::Mode]
      attr_reader :mode

      # @return [Harvesting::Schedules::Data]
      attr_reader :schedule_data

      # @return [Dry::Monads::Success(Hash)]
      # @return [Dry::Monads::Failure(:invalid_frequency_expression, <Symbol>)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield parse!
        end

        if errors.any?
          Failure[:invalid_frequency_expression, errors]
        else
          parsed = { mode:, frequency:, schedule_data:, }

          Success parsed
        end
      end

      wrapped_hook! def prepare
        @errors = []
        @frequency = nil
        @mode = "manual"
        @parsed = nil
        @schedule_data = Harvesting::Schedules::Data.new

        super
      end

      wrapped_hook! def parse
        return super if manual?

        result = Fugit.parse_cronish(frequency_expression)

        case result
        when Fugit::Cron
          @mode = "scheduled"
          @schedule_data.cron_expression = result.to_cron_s
          @schedule_data.time_zone = result.timezone
        else
          return halt!(:"frequency_expression.invalid")
        end

        frequencies = frequencies_for(result)

        @schedule_data.frequency_min = @frequency = frequencies.delta_min.seconds
        @schedule_data.frequency_max = frequencies.delta_max.seconds

        super
      end

      around_execute :with_halt!

      private

      # @param [Fugit::Cron] result
      # @return [Fugit::Cron::Frequency]
      def frequencies_for(result)
        first = result.next_time(Time.current)
        second = result.next_time(first)
        third = result.next_time(second)

        quick_deltas = [second - first, third - second]

        too_quick = quick_deltas.any? { _1 < MIN_FREQUENCY }

        return halt!(:"frequency_expression.too_frequent") if too_quick

        frequencies = result.brute_frequency

        # simplecov:disable
        return halt!(:"frequency_expression.too_frequent") if frequencies.delta_min < MIN_FREQUENCY
        # simplecov:enable

        return frequencies
      end

      def manual?
        frequency_expression.blank? || MANUALLY.match?(frequency_expression)
      end

      # @return [void]
      def with_halt!
        catch_halt do
          yield
        end
      end

      # @param [Symbol] message
      # @return [void]
      def halt!(message)
        @errors << message

        halt
      end
    end
  end
end
