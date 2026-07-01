# frozen_string_literal: true

module Schemas
  module Orderings
    module OrderBuilder
      # Builds an `ORDER BY` statement for an arbitrary schema property.
      #
      # @api private
      class BySchemaProperty < Base
        def attributes_for(definition)
          Array(property_attribute_for(definition.path))
        end

        private

        # @param [String] order_path
        # @return [Arel::Nodes::InfixOperation]
        def property_attribute_for(order_path)
          pattern = ancestor? ? Schemas::Orderings::OrderBuilder::ANCESTOR_PROPS_PATTERN : Schemas::Orderings::OrderBuilder::PROPS_PATTERN

          match = pattern.match order_path

          # simplecov:disable
          raise "Unparseable schema path: #{order_path}" unless match
          # simplecov:enable

          path = match[:path]

          type = match[:type].presence

          if type == "variable_date"
            nvd = join_for_variable_date path

            return [
              nvd[:value],
              nvd[:precision]
            ]
          end

          op = join_for_orderable_property path

          value_column = EntityOrderableProperty.value_column_for_type type

          expr = op[value_column]

          expr = order_boolean(expr) if type == "boolean"

          return [expr]
        end
      end
    end
  end
end
