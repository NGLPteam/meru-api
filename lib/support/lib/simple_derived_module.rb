# frozen_string_literal: true

module Support
  # @abstract
  class SimpleDerivedModule < Module
    extend Dry::Initializer
    extend ActiveModel::Callbacks

    define_model_callbacks :initialize, only: %i[after]

    # @return [String]
    attr_reader :inspection

    def initialize(...)
      super

      @inspection = derive_inspection(...)

      run_callbacks :initialize
    end

    def inspect = inspection

    private

    def derive_inspection(*args, **kwargs)
      "#{self.class.name}[#{args.map(&:inspect).join(", ")}#{", " unless args.empty? || kwargs.empty?}#{kwargs.map { |k, v| "#{k}: #{v.inspect}" }.join(", ")}]"
    end

    class << self
      def [](*args, **kwargs)
        registry.compute_if_absent(*args, **kwargs) do
          new(*args, **kwargs)
        end
      end

      # @!attribute [r] registry
      # @api private
      # A map storing the generated modules for each set of arguments.
      # @return [Concurrent::Map<Symbol, Class>]
      def registry
        @registry ||= Concurrent::Map.new
      end
    end
  end
end
