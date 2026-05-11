# frozen_string_literal: true

module Support
  module FrozenRecordHelpers
    # An abstract class that ties some integrations together with dry-schema,
    # arel, and Rails in general to FrozenRecord.
    #
    # @abstract
    class AbstractRecord < FrozenRecord::Base
      extend Dry::Core::ClassAttributes
      extend DefinesMonadicOperation

      include Dry::Core::Constants
      include ::Support::DefinesKlassNamePair

      self.abstract_class = true

      include ArelHelpers

      defines :calculated_attributes, type: Types::CalculatedAttributes
      defines :default_attributes, type: Types::DefaultAttributes
      defines :default_sql_values, type: Types::DefaultSQLValues
      defines :schema, type: Types::Schema.optional
      defines :sort_mapping, type: Types::Array.of(Types::String)
      defines :type_registry, type: Types::TypeRegistry

      calculated_attributes EMPTY_HASH

      default_attributes EMPTY_HASH

      default_sql_values EMPTY_ARRAY

      schema nil

      sort_mapping EMPTY_ARRAY

      scope :none, -> { where(_non_existing_: :match) }

      type_registry Support::FrozenRecordHelpers::DefaultTypeRegistry

      # @see #slice
      # @param [<Symbol>] keys
      # @return [{ Symbol => Object }]
      def deconstruct_keys(*keys)
        slice(*keys)
      end

      def slice(*keys)
        keys.flatten.index_with do |key|
          public_send key
        end
      end

      # @param [Symbol] key
      # @return [Arel::Nodes::Node]
      def to_sql_value(key)
        arel_quote self[key]
      end

      def to_upsert
        slice(*self.class.default_sql_values)
      end

      # @param [<Symbol>] key
      # @return [<Arel::Nodes::Node>]
      def to_values(*keys)
        keys.flatten!

        if keys.blank?
          return [] if self.class.default_sql_values.blank?

          return to_values(*self.class.default_sql_values)
        end

        keys.map do |key|
          to_sql_value key
        end
      end

      private

      def arel_table
        @arel_table ||= ->(key) { to_sql_value(key) }
      end

      def arel_column_matcher
        @arel_column_matcher ||= ->(o) { attributes.key?(o.to_s) }
      end

      # @param [#to_json] value
      # @return [Arel::Nodes::Quoted]
      def arel_quote_json(value)
        arel_quote value.to_json
      end

      class << self
        # @note We repurpose this built-in method to apply our schema
        def assign_defaults!(record)
          return super if schema.blank?

          record = record.deep_stringify_keys

          record.reverse_merge!(default_attributes.deep_stringify_keys)

          calculated_attributes.each do |attr, calculator|
            # :nocov:
            next if record.key?(attr)
            # :nocov:

            record[attr] = calculator.(record)
          end

          result = schema.call record

          return result.to_monad.value! if result.failure?

          result.to_h.stringify_keys.transform_values(&:freeze)
        end

        def calculates!(attr, &calculator)
          calculated = calculated_attributes.merge(attr.to_s => calculator)

          calculated_attributes calculated
        end

        def calculates_format!(attr, format)
          calculates! attr do |record|
            format % record.symbolize_keys
          end
        end

        def calculates_id_from!(*fields, attr: :id, separator: ?#)
          fields.flatten!

          format = fields.map do |field|
            "%<#{field}>s"
          end.join(separator)

          calculates_format! attr, format
        end

        def default_attributes!(**defaults)
          default_attributes defaults.deep_stringify_keys
        end

        # @api private
        # @return [void]
        def extract_sort_mapping!
          sort_mapping schema.key_map.keys.map(&:name).freeze
        end

        # @return [void]
        def schema!(types: type_registry, &block)
          defined = Dry::Schema.Params do
            config.types = types

            instance_eval(&block)
          end

          schema defined
        ensure
          extract_sort_mapping!
        end

        # @param [<Hash>, Hash] input
        # @return [<Hash>, Hash, Object]
        def sort_attributes_in(input)
          case input
          when Array
            input.map { sort_attributes_in _1 }
          when Hash
            input.sort_by do |attr_name, _|
              [
                sort_mapping.index(attr_name) || 10_000,
                attr_name
              ]
            end.to_h
          else
            # :nocov:
            input
            # :nocov:
          end
        end

        # @return [<Hash>]
        def to_upsert
          all.map(&:to_upsert)
        end

        # @param [<Symbol>] key
        # @return [Arel::Nodes::ValuesList]
        def to_values_list(*keys)
          sqlized = to_values(*keys).map do |row|
            row.map do |value|
              case value
              when Arel::Nodes::Quoted then value.expr
              else
                value
              end
            end
          end

          Arel::Nodes::ValuesList.new sqlized
        end

        # @param [<Symbol>] key
        # @return [<<Arel::Nodes::Node>>]
        def to_values(*keys)
          all.map do |record|
            record.to_values(*keys)
          end
        end
      end
    end
  end
end
