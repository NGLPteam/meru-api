# frozen_string_literal: true

# A concern that maintains foreign key associations for polymorphic tables. It creates some duplication,
# but doubles up on data integrity.
module AssignsPolymorphicForeignKey
  extend ActiveSupport::Concern

  # @param [#to_sym] association_name
  # @return [AssignsPolymorphicForeignKey::Definition, nil]
  def polymorphic_foreign_key_definition_for(association_name)
    self.class.polymorphic_foreign_keys[association_name]
  end

  # @param [ApplicationRecord] model
  # @param [AssignsPolymorphicForeignKey::Definition] definition
  # @return [Symbol]
  def polymorphic_foreign_key_for(model, definition)
    definition.foreign_key_for model
  end

  module ClassMethods
    def polymorphic_foreign_keys
      @polymorphic_foreign_keys ||= defined?(super) ? super.deep_dup : {}.with_indifferent_access
    end

    def assign_polymorphic_foreign_key!(name, *direct_foreign_keys, required_interface: nil, **mapped_foreign_keys)
      direct_foreign_keys.flatten!

      foreign_keys = direct_foreign_keys.to_h do |key|
        [key.to_sym, key.to_sym]
      end.merge(mapped_foreign_keys)

      options = {}

      options[:required_interface] = required_interface unless required_interface.nil?

      definition = Definition.new(name, foreign_keys, **options)

      polymorphic_foreign_keys[definition.name] = definition

      mod = ValidationMethods.new definition

      include mod

      before_validation definition.validation_method_name
    end
  end

  # @api private
  class Definition
    include Dry::Initializer.define -> do
      param :name, ::Support::Types::DefinitionName
      param :foreign_keys, ::Support::Types::SymbolicMap
      option :required_interface, ::Support::Types::Module, optional: true
      option :validation_method_name, ::Support::Types::Symbol, default: proc { :"sync_#{name}!" }
    end

    # @param [ApplicationRecord] model
    # @return [Symbol]
    def foreign_key_for(model)
      base_key = model.model_name.i18n_key

      foreign_keys.key base_key
    end

    def foreign_key_targets
      foreign_keys.keys
    end

    def foreign_key_assignments_for(model_key, model)
      foreign_key_targets.index_with do |key|
        model_key == key ? model : nil
      end
    end
  end

  # @api private
  class ValidationMethods < Module
    delegate :validation_method_name, to: :@definition

    def initialize(definition)
      @definition = definition

      generate_methods!
    end

    private

    # @return [void]
    def generate_methods!
      defn = @definition

      define_method(validation_method_name) do
        model = public_send(defn.name)

        foreign_key = polymorphic_foreign_key_for(model, defn)&.to_sym

        if foreign_key.in?(defn.foreign_keys)
          assignments = defn.foreign_key_assignments_for(foreign_key, model)

          assign_attributes assignments
        else
          errors.add defn.name, "is not set with a valid model: #{model.model_name}"
        end
      end
    end
  end
end
