# frozen_string_literal: true

module Templates
  module Drops
    # This serves as a wrapper around schema properties that provides a slightly
    # more fluent interface for interacting with them than just inserting the
    # raw values into the liquid context.
    #
    # It allows for things like:
    #
    # ```liquid
    # {% if props.foo.exists %}
    #   Foo: {{props.foo}}
    # {% else %}
    #   Foo: Was Not Set
    # {% endif %}
    # ```
    #
    # @see Schemas::Properties::Reader#to_liquid
    class PropertyValueDrop < Templates::Drops::AbstractDrop
      include Enumerable

      # Boolean complement of {#missing}. Works like `#present?` in Rails parlance.
      #
      # @return [Boolean]
      attr_reader :exists

      # Boolean complement of {#exists}. Works like `#blank?` in Rails parlance.
      #
      # @return [Boolean]
      attr_reader :missing

      # @param [Schemas::Properties::Reader] reader
      def initialize(reader)
        super()

        @reader = reader
        @property = reader.property
        @full_path = property.full_path
        @type = property.type

        @value = normalize_value reader.value

        @missing = calculate_missing
        @exists = !@missing

        @inner_representation = build_inner_representation
      end

      def each
        # simplecov:disable
        raise Liquid::ContextError, "tried to enumerate non-enumerable property: #{@full_path}" unless array?
        # simplecov:enable

        @inner_representation.each do |elm|
          yield elm
        end
      end

      # @note This defers to the inner representation in case we are wrapping
      #   around a drop class that adds further methods for the property.
      # @param [#to_s] method_or_key
      # @raise [Liquid::UndefinedDropMethod]
      def liquid_method_missing(method_or_key)
        case @inner_representation
        in ::Liquid::Drop
          @inner_representation.invoke_drop(method_or_key)
        else
          super
        end
      end

      def to_s
        if array?
          @inner_representation.map(&:to_s).to_sentence
        else
          @inner_representation.to_s
        end
      end

      private

      # @return [Schemas::Properties::Scalar::Base]
      attr_reader :property

      delegate :array?, to: :property

      # @return [Liquid::Drop, Object, nil]
      def build_inner_representation
        return Array(@value).map { build_inner_representation_for(_1) } if array?

        case @type
        in "boolean"
          Templates::Drops::BooleanDrop.new @value
        in "full_text"
          Templates::Drops::FullTextDrop.new @value
        in "markdown"
          Templates::Drops::FullTextDrop.new @value
        in "url"
          Templates::Drops::URLDrop.new @value
        in "variable_date"
          Templates::Drops::VariablePrecisionDateDrop.new @value
        else
          build_inner_representation_for(@value)
        end
      end

      # @param [Object] value
      # @return [Object, nil]
      def build_inner_representation_for(value)
        case value
        when ::Liquifies
          value.to_liquid
        else
          value&.to_liquid
        end
      end

      # @return [Boolean]
      def calculate_missing
        case @value
        when VariablePrecisionDate
          @value.none?
        else
          @value.blank?
        end
      end

      # @param [Object] raw_value
      # @return [Object]
      def normalize_value(raw_value)
        case @type
        in "full_text"
          Schemas::PropertyValues::FullText.normalize(raw_value)
        in "markdown"
          Schemas::PropertyValues::FullText.markdown(raw_value)
        in "url"
          Schemas::PropertyValues::URL.normalize(raw_value).presence
        else
          raw_value
        end
      end
    end
  end
end
