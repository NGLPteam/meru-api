# frozen_string_literal: true

module EsploroSchema
  module Common
    # The base class for all elements and complex types when parsing Esploro-encoded data.
    #
    # @abstract
    class AbstractMapper < Lutaml::Model::Serializable
      extend Dry::Core::ClassAttributes

      include Dry::Core::Constants

      include EsploroSchema::Constants

      PropertyMapping = EsploroSchema::Types::Hash.map(
        EsploroSchema::Types::Symbol,
        EsploroSchema::Types.Instance(::EsploroSchema::Common::PropertyDefinition)
      )

      defines :property_mapping, type: PropertyMapping

      property_mapping EMPTY_HASH

      # When unwrapping attributes, it's possible that we may want
      # to grab attributes of the same kind from a nested property
      # and merge them together.
      #
      # This is to solve the issue of the two elements that overlap:
      #
      # * {EsploroSchema::Elements::EsploroData}
      # * {EsploroSchema::Elements::EsploroRecord}
      #
      # @api private
      # @return [<EsploroSchema::Common:AbstractMapper, Symbol>]
      def wrapped_attribute_sources
        @wrapped_attribute_sources ||= build_wrapped_attribute_sources
      end

      private

      # @abstract
      # @return [<EsploroSchema::Common:AbstractMapper, Symbol>]
      def build_wrapped_attribute_sources
        [self]
      end

      # @return [<EsploroSchema::Common:AbstractMapper>]
      def resolve_wrapped_attribute_sources
        wrapped_attribute_sources.map do |source|
          case source
          when EsploroSchema::Common::AbstractMapper then source
          when Symbol then __send__(source)
          else
            # simplecov:disable
            raise "Invalid wrapped attribute source: #{source.inspect}"
            # simplecov:enable
          end
        end.compact
      end

      # @param [<Symbol>] wrapped_name
      # @return [<Object>]
      def unwrap_attribute_values_for(wrapped_name)
        sources = resolve_wrapped_attribute_sources

        sources.flat_map do |source|
          wrappers = Array(source.public_send(wrapped_name))

          wrappers.flat_map do |wrapper|
            wrapper.try(:wrapped_values)
          end
        end.compact
      end

      class << self
        # @return [<EsploroSchema::Common::PropertyDefinition>]
        def properties
          property_mapping.values.freeze
        end

        # A thin wrapper around `Lutaml::Model::Serializable`'s attribute
        # definition that allows us to define some additional helper methods
        # for some of the more complex attributes.
        #
        # @param [Symbol] name
        # @param [Class, Symbol] type
        # @param [{ Symbol => Object }] options
        # @return [void]
        def property!(name, type, **options)
          @mapping_options = { **options, raw_type: type, name:, }

          case type
          when EsploroSchema::Common::AbstractWrapper::Subclass
            define_wrapped_property!(name, type, **options)
          else
            attribute name, type, **options
          end
        ensure
          record_property!
        end

        private

        # @return [void]
        def define_wrapped_property!(unwrapped_name, type, **options)
          wrapped_name = :"wrapped_#{unwrapped_name}"

          options[:collection] = true

          attribute wrapped_name, type, **options

          accessor = EsploroSchema::Common::WrappedAttributeAccessor.new(unwrapped_name, wrapped_name, type:)

          include accessor

          @mapping_options.merge!(name: wrapped_name, wrapper: true, unwrapped_name:, wrapped_name:, collection: true)
        end

        # @return [void]
        def record_property!
          @mapping_options => { name:, }

          attribute = attributes.fetch(name)

          options = @mapping_options.merge(attribute:)

          property = EsploroSchema::Common::PropertyDefinition.new(**options)

          properties = property_mapping.merge(name => property).freeze

          property_mapping properties
        end
      end
    end
  end
end
