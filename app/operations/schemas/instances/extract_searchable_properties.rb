# frozen_string_literal: true

module Schemas
  module Instances
    # Accept a {HasSchemaDefinition schema instance} and extract any given searchable properties from it.
    class ExtractSearchableProperties
      include Dry::Monads[:do, :result]
      include MeruAPI::Deps[
        instance_for: "schemas.utility.instance_for",
        read_searchable_values: "schemas.instances.read_searchable_property_values",
      ]

      # @param [HasSchemaDefinition, Entity, EntityLink] schema_instance (@see Schemas::Utility::InstanceFor for acceptable values to pass)
      # @param [Schemas::Properties::Context, nil] context
      # @return [Hash]
      def call(entity, context: nil)
        schema_instance = instance_for.call entity

        schema_version = schema_instance.schema_version

        values = yield read_searchable_values.call(schema_instance, context:)

        entity_attrs = base_attrs_for schema_instance

        properties = schema_version.schema_version_properties.searchable.reject do |svp|
          # These are handled by {Schemas::Texts::Writer}.
          svp.with_full_text_type? || svp.with_markdown_type?
        end

        searchable_attributes = properties.map do |svp|
          attrs = svp.to_entity_property_attributes

          entity_attrs.merge attrs.merge(all_values_for(svp, values))
        end

        searchable_attributes += core_properties_for(entity)

        props = yield upsert_searchable_properties! searchable_attributes

        result = { props: }

        Success result
      end

      private

      def upsert_searchable_properties!(attributes)
        # :nocov:
        return Success(0) if attributes.blank?
        # :nocov:

        res = EntitySearchableProperty.upsert_all(
          attributes,
          unique_by: %i[entity_type entity_id path]
        )

        Success res.length
      end

      def all_values_for(svp, values)
        attrs = {}

        attrs[:raw_value] = raw_value = values[svp.path]

        attrs[:boolean_value] = raw_value.present?
        attrs[:citext_value] = svp.citextual? ? raw_value.to_s.presence : nil
        attrs[:date_value] = parse_date raw_value
        attrs[:float_value] = svp.with_float_type? ? raw_value.to_f : nil
        attrs[:integer_value] = svp.with_integer_type? ? raw_value.to_i : nil
        attrs[:text_value] = svp.textual? ? raw_value.to_s.presence : nil
        attrs[:text_array_value] = svp.with_multiselect_type? ? Array(raw_value) : []
        attrs[:timestamp_value] = svp.with_timestamp_type? ? raw_value : nil
        attrs[:variable_date_value] = svp.with_variable_date_type? ? raw_value : nil

        return attrs
      end

      def parse_date(raw_value)
        case raw_value
        when Date, Time, VariablePrecisionDate
          raw_value.to_date
        end
      end

      def parse_time(raw_value)
        case raw_value
        when Time then raw_value
        when Date then raw_value.to_time
        when VariablePrecisionDate then raw_value.to_date&.to_time
        end
      end

      def core_properties_for(entity)
        [].tap do |props|
          props << core_text_property(entity, :doi)
          props << core_text_property(entity, :issn)
          props << core_date_property(entity, :created_at)
          props << core_date_property(entity, :updated_at)
          props << core_date_property(entity, :published)
        end
      end

      def core_property_for(entity, attr, type)
        attrs = base_attrs_for entity

        attrs[:path] = "$#{attr}$"

        attrs[:raw_value] = raw_value = entity.respond_to?(attr) ? entity.public_send(attr) : nil

        attrs[:type] =
          case raw_value
          when String then "string"
          when Time then "timestamp"
          when VariablePrecisionDate then "variable_date"
          else
            # :nocov:
            case type
            when :date then "date"
            when :text then "string"
            else
              "unknown"
            end
            # :nocov:
          end

        attrs[:boolean_value] = raw_value.present?

        attrs[:date_value] = type == :date ? parse_date(raw_value) : nil

        attrs[:text_value] = type == :text ? raw_value.to_s.presence : nil

        attrs[:timestamp_value] = type == :date ? parse_time(raw_value) : nil

        attrs[:variable_date_value] = type == :date ? VariablePrecisionDate.parse(raw_value) : VariablePrecisionDate.none

        return attrs
      end

      def base_attrs_for(entity)
        entity.to_entity_pair.merge(
          schema_version_property_id: nil,
          path: nil,
          type: "unknown",
          raw_value: nil,
          boolean_value: nil,
          citext_value: nil,
          date_value: nil,
          float_value: nil,
          integer_value: nil,
          text_value: nil,
          text_array_value: [],
          timestamp_value: nil,
          variable_date_value: nil,
        )
      end

      def core_date_property(entity, attr)
        core_property_for(entity, attr, :date)
      end

      def core_text_property(entity, attr)
        core_property_for(entity, attr, :text)
      end
    end
  end
end
