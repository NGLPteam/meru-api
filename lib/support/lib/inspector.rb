# frozen_string_literal: true

module Support
  class Inspector
    include Support::Inspecting::Types
    include Dry::Initializer[undefined: false].define -> do
      param :inspectable, Types::Any

      option :skip_internal_inspect, Types::Params::Bool, default: proc { false }
    end

    def initialize(...)
      super

      @attrs_for_inspect = {}
      @wrapper_name = @attrs = nil

      derive_inspection!
    end

    # @return [{ Symbol => Object }]
    attr_reader :attrs_for_inspect

    # @return [String]
    attr_reader :attrs

    # @return [String]
    attr_reader :inspection

    # @return [String, nil]
    attr_reader :wrapper_name

    def to_s = inspection.to_s

    alias to_str to_s

    private

    def compile_attrs
      @attrs_for_inspect.map do |key, value|
        "#{key}: #{value.inspect}"
      end.join(", ")
    end

    # @return [void]
    def extract_all_attrs!
      extract_attr_if!(HasId, :id)
      extract_attr_if!(HasName, :name)
      extract_attr_if!(HasTitle, :title)
    end

    # @param [Symbol] key
    # @param [Object] value
    # @return [void]
    def extract_attr!(key)
      @attrs_for_inspect[key] = inspectable.public_send(key)
    end

    # @param [Dry::Types::Type] type
    # @param [Symbol] key
    # @return [void]
    def extract_attr_if!(type, key)
      extract_attr!(key) if type.valid?(inspectable)
    end

    # @return [void]
    def extract_wrapper_name!
      case inspectable
      in ModelLike => model_like
        @wrapper_name = model_like.model_name.to_s
      else
        @wrapper_name = inspectable.class.name
      end
    end

    # @return [void]
    def process_inspectable!
      extract_all_attrs!

      extract_wrapper_name!

      @attrs = compile_attrs
    end

    # @return [String]
    def derive_inspection
      return inspectable.internal_inspect if !skip_internal_inspect && inspectable.respond_to?(:internal_inspect)

      process_inspectable!

      if @attrs.present?
        "#{wrapper_name}(#{attrs})"
      else
        inspectable.inspect
      end
    end

    # @return [void]
    def derive_inspection!
      @inspection = derive_inspection.to_s.presence || inspectable.inspect
    end

    class << self
      # @param [Object] object
      # @return [String]
      def inspect(object, **options) = new(object, **options).to_s
    end
  end
end
