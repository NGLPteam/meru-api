# frozen_string_literal: true

module JournalSources
  module Parsers
    # When other parsers have failed, this one may kick-in based on whether or not
    # it should
    class Fallback < JournalSources::Parsers::Abstract
      include Dry::Effects.Resolve(:auto_create_volumes_and_issues)

      parsed_klass JournalSources::Parsed::Full

      def try_parsing_inputs!(inputs)
        maybe_auto_create!(input: inputs.first)
      end

      def auto_create_volumes_and_issues?
        auto_create_volumes_and_issues { false }
      end

      # @param [String] input
      # @return [void]
      def maybe_auto_create!(input:)
        # simplecov:disable
        return unless auto_create_volumes_and_issues?

        check_parsed!(input:, volume: ?1, issue: ?1)
        # simplecov:enable
      end
    end
  end
end
