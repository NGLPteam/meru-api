# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      class Tags < Base
        include ValidatesSize

        array! :str?

        fillable!

        schema_type! :string

        graphql_value_key :tags

        attribute :default, :string_array

        def add_to_rules!(context)
          super

          context.rule(path).each(:tag_format)
        end
      end
    end
  end
end
