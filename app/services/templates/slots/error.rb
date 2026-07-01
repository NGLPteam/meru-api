# frozen_string_literal: true

module Templates
  module Slots
    # @note This roughly wraps around `Liquid::Error` and its subclasses.
    # @see Types::TemplateSlotErrorType
    class Error
      include Support::EnhancedStoreModel

      attribute :line_number, :integer
      attribute :markup_context, :string
      attribute :message, :string
      attribute :exception_klass, :string
      attribute :backtrace, :string_array

      def blank?
        super || message.blank?
      end

      def file_system_error?
        exception_klass == "Liquid::FileSystemError"
      end

      def syntax_error?
        exception_klass == "Liquid::SyntaxError"
      end

      class << self
        # @param [Liquid::Error, Exception] source
        # @return [Templates::Slots::Error]
        def from(source)
          case source
          when Liquid::Error
            new(message: source.message, markup_context: source.markup_context, line_number: source.line_number, exception_klass: source.class.name)
          when Exception
            new(message: source.message, exception_klass: source.class.name, backtrace: source.backtrace)
          else
            # simplecov:disable
            raise TypeError, "invalid Template Slot Error Source: #{source.inspect}"
            # simplecov:enable
          end
        end
      end
    end
  end
end
