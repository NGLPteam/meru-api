# frozen_string_literal: true

module Templates
  module Drops
    # @abstract
    class AbstractPropertiesDrop < Templates::Drops::AbstractDrop
      defines :group_mode, type: Types::Bool

      group_mode false

      # @param [HierarchicalEntity, Schemas::Properties::GroupReader] init_arg
      def initialize(init_arg)
        super()

        build_with(init_arg)

        @identifier = group_mode? ? "props.#{group_name}" : "props"
      end

      def liquid_method_missing(name)
        fetch_property_drop(name)
      rescue Entities::UnknownProperty => e
        raise Liquid::UndefinedDropMethod, e.message
      end

      def to_s
        # simplecov:disable
        raise Liquid::ContextError, "Tried to render `#{@identifier}` in scalar context"
        # simplecov:enable
      end

      private

      # @return [HierarchicalEntity]
      attr_reader :entity

      # @return [String, nil]
      attr_reader :group_name

      # @return [{ String => }]
      attr_reader :prop_drops

      # @param [HierarchicalEntity, Schemas::Properties::GroupReader] init_arg
      # @return [void]
      def build_with(init_arg)
        case init_arg
        in HierarchicalEntity => entity
          build_with_entity(entity)
        in Schemas::Properties::GroupReader => reader
          build_with_group_reader(reader)
        else
          # simplecov:disable
          raise TypeError, "unexpected init_arg for props drop: #{init_arg.inspect}"
          # simplecov:enable
        end
      end

      def build_with_entity(entity)
        @entity = entity
        @reader = @group_name = nil
        @prop_drops = props_to_drops(entity.read_properties!)
      end

      def build_with_group_reader(reader)
        @reader = reader
        @entity = reader.context.instance
        @group_name = reader.path
        @prop_drops = props_to_drops(@reader.properties)
      end

      # @param [String] property_name
      # @raise [Entities::UnknownProperty]
      def fetch_property_drop(property_name)
        @prop_drops.fetch(property_name) do
          raise Entities::UnknownProperty.new(property_name:, entity:, group_name:)
        end
      end

      def group_mode?
        group_name.present?
      end

      # @see Schemas::Properties::BaseReader#to_liquid
      # @param [HierarchicalEntity] entity
      # @param [<Schemas::Properties::BaseReader>] properties
      # @return [{ String, Symbol => Templates::Drops::GroupPropertyDrop, Templates::Drops::PropertyValueDrop }]
      def props_to_drops(properties)
        properties.index_by(&:path).transform_values do |reader|
          reader.to_liquid
        end
      end
    end
  end
end
