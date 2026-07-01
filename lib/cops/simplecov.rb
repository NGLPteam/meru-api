# frozen_string_literal: true

module RuboCop
  module Cop
    module Simplecov
      class LegacySkipCoverage < Base
        extend AutoCorrector

        MSG = "Use `%<replacement>s` instead of legacy `# :nocov:` syntax."
        UNMATCHED_MSG = "Legacy `# :nocov:` markers must be in pairs; missing closing marker to re-enable coverage."
        LEGACY_NOCOV_PATTERN = /^\s*#\s*:nocov:\s*$/

        def on_new_investigation
          super

          comments = legacy_nocov_comments

          comments.each_slice(2).with_index do |pair, pair_index|
            if pair.size == 1
              add_offense(pair.first.loc.expression, message: UNMATCHED_MSG)
              next
            end

            pair.each_with_index do |comment, marker_index|
              replacement = replacement_for(pair_index, marker_index)

              add_offense(comment.loc.expression, message: format(MSG, replacement:)) do |corrector|
                corrector.replace(comment.loc.expression, replacement)
              end
            end
          end
        end

        private

        def legacy_nocov_comments
          processed_source.comments.select { |comment| comment.text.match?(LEGACY_NOCOV_PATTERN) }
        end

        def replacement_for(_pair_index, marker_index)
          marker_index.zero? ? "# simplecov:disable" : "# simplecov:enable"
        end
      end

      class SkipCoverageConsistency < Base
        NESTED_DISABLE_MSG = "Found `# simplecov:disable` before re-enabling a previous skip-coverage block."
        UNCLOSED_DISABLE_MSG = "Missing `# simplecov:enable` before end of file for this `# simplecov:disable`."
        DISABLE_PATTERN = /^\s*#\s*simplecov:disable\s*$/
        ENABLE_PATTERN = /^\s*#\s*simplecov:enable\s*$/

        def on_new_investigation
          super

          open_disable = nil

          processed_source.comments.each do |comment|
            if disable_comment?(comment)
              if open_disable
                add_offense(comment.loc.expression, message: NESTED_DISABLE_MSG)
              else
                open_disable = comment
              end

              next
            end

            open_disable = nil if open_disable && enable_comment?(comment)
          end

          return unless open_disable

          add_offense(open_disable.loc.expression, message: UNCLOSED_DISABLE_MSG)
        end

        private

        def disable_comment?(comment)
          comment.text.match?(DISABLE_PATTERN)
        end

        def enable_comment?(comment)
          comment.text.match?(ENABLE_PATTERN)
        end
      end
    end
  end
end
