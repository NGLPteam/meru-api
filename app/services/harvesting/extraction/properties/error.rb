# frozen_string_literal: true

module Harvesting
  module Extraction
    module Properties
      # @note This roughly wraps around `Liquid::Error` and its subclasses.
      class Error < ::Harvesting::Extraction::Error
        attribute :path, Types::Coercible::String

        attribute :subpath, Types::Coercible::String

        attribute? :coercion_error, Types::Bool.default(false)

        # @return [void]
        def write_log!
          # :nocov:
          return if blank?
          # :nocov:

          trace = Rails.backtrace_cleaner.clean(Array(backtrace))

          tags = [].tap do |a|
            a << "coercion_error" if coercion_error
            a << "syntax_error" if syntax_error?
          end

          logger.error("properties.#{path}.#{subpath}: #{message}", markup_context:, exception_klass:, path:, tags:, trace:)
        end

        class << self
          # @param [Harvesting::Extraction::Error, Liquid::Error, Exception] source
          # @return [Templates::Slots::Error]
          def from(path, subpath, source)
            case source
            when ::Harvesting::Extraction::Error
              new(path:, subpath:, message: source.message, markup_context: source.markup_context, exception_klass: source.exception_klass, backtrace: source.backtrace)
            when Liquid::Error
              # :nocov:
              new(path:, subpath:, message: source.message, markup_context: source.markup_context, exception_klass: source.class.name)
              # :nocov:
            when Exception
              # :nocov:
              new(path:, subpath:, message: source.message, exception_klass: source.class.name, backtrace: source.backtrace)
              # :nocov:
            else
              # :nocov:
              raise TypeError, "invalid Harvesting Extraction Error Source: #{source.inspect}"
              # :nocov:
            end
          end
        end
      end
    end
  end
end
