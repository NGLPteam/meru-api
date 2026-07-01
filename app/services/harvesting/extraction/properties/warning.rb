# frozen_string_literal: true

module Harvesting
  module Extraction
    module Properties
      # @note This roughly wraps around `ActiveRecord` and its subclasses.
      class Warning < ::Harvesting::Extraction::Error
        DEFAULT_TAGS = %w[validation_error].freeze

        attribute :path, Types::Coercible::String

        attribute? :base, Types::Bool.default(false)

        attribute? :subpath, Types::Coercible::String.optional

        def prefix
          if base
            "properties.#{path}"
          else
            "properties.#{path}.#{subpath}"
          end
        end

        # @return [void]
        def write_log!
          # simplecov:disable
          return if blank?
          # simplecov:enable

          trace = Rails.backtrace_cleaner.clean(Array(backtrace))

          tags = DEFAULT_TAGS.dup

          logger.warn("#{prefix}: #{message}", path:, tags:, trace:)
        end

        class << self
          # @param [String] path
          # @param [String, nil] subpath
          # @param [ActiveModel::Error] error
          # @return [Harvesting::Extraction::Properties::Warning]
          def from_validation(path:, error:, subpath: nil)
            base = error.base.present?

            attrs = {
              path:,
              base:,
              message: error.message,
              subpath:,
            }

            new(**attrs)
          end
        end
      end
    end
  end
end
