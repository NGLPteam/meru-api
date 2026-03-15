# frozen_string_literal: true

module Schemas
  module Properties
    module References
      # @abstract
      # A schematic reference to other models in the system.
      #
      # Property definition classes should not include this directly.
      #
      # @see Schemas::Properties::References::Collected
      # @see Schemas::Properties::References::Scalar
      module Model
        extend ActiveSupport::Concern

        included do
          reference!

          # @!scope class
          # @!attribute [r] model_types
          # A list of models that this reference can refer to.
          # @return [<Class>]
          defines :model_types, type: ::Support::Models::Types::ModelClassList

          model_types Dry::Core::Constants::EMPTY_ARRAY

          complex true

          graphql_value_key type_reference
        end

        def apply_schema_type_to(macro)
          if !actually_required? && scalar_reference?
            macro.maybe(schema_type)
          else
            macro.value(schema_type)
          end
        end

        def add_to_rules!(context)
          super

          if collected_reference?
            context.rule(path).each(typed_schematic_reference: model_types)
          else
            context.rule(path).validate(typed_schematic_reference: model_types)
          end
        end

        # @see .model_types
        # @return [<Class>] the list of models that this reference can refer to.
        def model_types = self.class.model_types

        module ClassMethods
          # Declare a single {.model_types model type} that this type can refer to.
          #
          # @param [Class] model
          # @return [void]
          def model_type!(model)
            model_types! model
          end

          # Declare the {.model_types} that this type can refer to.
          #
          # @param [<Class>] models
          # @return [void]
          def model_types!(*models)
            models.flatten!

            merged_types = Array(model_types) | models

            model_types merged_types

            matcher_type = collected_reference? ? :collected_reference : :scalar_reference

            schema_type! matcher_type
          end
        end
      end
    end
  end
end
