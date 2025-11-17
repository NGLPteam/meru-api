# frozen_string_literal: true

module Contributors
  # @see Contributors::Lookup
  class Finder
    include Dry::Monads[:result, :do]
    include Dry::Initializer[undefined: false].define -> do
      option :field, Contributors::Types::LookupField
      option :value, Contributors::Types::String
      option :order, Contributors::Types::LookupOrder, default: proc { "RECENT" }
    end

    # @return [Hash]
    attr_reader :options

    def call
      return Failure[:invalid, "must provide a non-blank value"] if value.blank?

      yield build_options

      Success options
    end

    private

    # @return [Dry::Monads::Result<void>]
    def build_options
      find_by = yield derive_find_by_from_field

      order = yield derive_order_expression

      @options = { find_by:, order:, value: }

      Success()
    end

    def derive_find_by_from_field
      Success field
    end

    def derive_order_expression
      # :nocov:
      unless order == "OLDEST"
        Success(created_at: :desc)
      else
        Success(created_at: :asc)
      end
      # :nocov:
    end
  end
end
