# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      class Multiselect < Base
        include HasSelectOptions
        include ValidatesSize

        array! :str?

        fillable!

        searchable!

        schema_type! :string

        graphql_value_key :selections

        attribute :default, :string_array

        def add_to_rules!(context)
          super

          prop = self

          context.rule(path).each do
            key.failure("must be a known option") unless (!prop.actually_required? && value.blank?) || value.in?(prop.option_values)
          end
        end

        def build_array_element_predicates
          super.merge(
            included_in?: option_values
          )
        end
      end
    end
  end
end
