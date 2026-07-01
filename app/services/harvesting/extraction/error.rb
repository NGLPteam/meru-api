# frozen_string_literal: true

module Harvesting
  module Extraction
    # @note This roughly wraps around `Liquid::Error` and its subclasses.
    class Error < Support::FlexibleStruct
      include Dry::Core::Constants
      include Harvesting::WithLogger

      attribute :message, Types::String

      attribute? :markup_context, Types::String.optional
      attribute? :exception_klass, Types::String.optional
      attribute? :backtrace, Types::Coercible::Array.of(Types::String).default(EMPTY_ARRAY)

      def empty?
        message.blank?
      end

      def file_system_error?
        exception_klass == "Liquid::FileSystemError"
      end

      def syntax_error?
        exception_klass == "Liquid::SyntaxError"
      end

      # @return [void]
      def write_log!(prefix:, path: nil)
        # simplecov:disable
        return if blank?
        # simplecov:enable

        trace = Rails.backtrace_cleaner.clean(Array(backtrace))

        tags = [].tap do |a|
          a << "syntax_error" if syntax_error?
        end

        logger.error("#{prefix}: #{message}", markup_context:, exception_klass:, path:, tags:, trace:)
      end

      class << self
        # @param [Liquid::Error, Exception] source
        # @return [Templates::Slots::Error]
        def from(source)
          case source
          when Liquid::Error
            new(message: source.message, markup_context: source.markup_context, exception_klass: source.class.name)
          when Exception
            new(message: source.message, exception_klass: source.class.name, backtrace: source.backtrace)
          else
            # simplecov:disable
            raise TypeError, "invalid Harvesting Extraction Error Source: #{source.inspect}"
            # simplecov:enable
          end
        end
      end
    end
  end
end
