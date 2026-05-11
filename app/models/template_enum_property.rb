# frozen_string_literal: true

class TemplateEnumProperty < ::ApplicationFrozenRecord
  include Dry::Core::Equalizer.new(:name)
  include Dry::Core::Memoizable
  include ScopedTranslatableAttributes

  schema!(types: ::Templates::TypeRegistry) do
    required(:name).filled(:enum_property_name)
    required(:category).value(:enum_property_category)
    optional(:default).maybe(:string)
    optional(:description).maybe(:stripped_string)
  end

  default_attributes!(
    category: "none",
    description: "An enumerated value associated with the templating subsystem."
  )

  configure_i18n_scoped_attributes!(
    namespace: :template_enums,
    default_key_from: :category,
    key_from: :name,
    values_from: :enum_values,
  )

  i18n_scoped_attribute! :description

  self.primary_key = :name

  add_index :name, unique: true

  scope :backgrounds, -> { where(category: "background") }
  scope :selection_modes, -> { where(category: "selection_mode") }
  scope :variants, -> { where(category: "variant") }

  def categorized?
    !uncategorized?
  end

  def uncategorized?
    category == "none"
  end

  memoize def dry_type
    ApplicationRecord.dry_pg_enum(name, default:)
  end

  # @return [<String>]
  memoize def enum_values
    ApplicationRecord.pg_enum_values(name)
  end

  # @!group Generator / Introspection Helpers

  def gql_description(indent: 4)
    description.to_s.indent(indent).strip
  end

  # @return [String]
  memoize def gql_type_file_name
    "#{File.basename(gql_type_klass_name.underscore)}.rb"
  end

  # @return [Class]
  memoize def gql_type_klass
    gql_type_full_klass_name.safe_constantize
  end

  # @return [String]
  memoize def gql_type_full_klass_name
    "::Types::#{gql_type_klass_name}"
  end

  # @return [String]
  memoize def gql_type_klass_name
    "#{klass_name}Type"
  end

  # @return [Pathname]
  memoize def gql_type_path_name
    Rails.root.join("app", "graphql", "types", gql_type_file_name)
  end

  def i18n_default_key?
    categorized? && super
  end

  # @return [String]
  memoize def klass_name
    name.classify
  end

  # @return [String]
  def shale_mapper_type_klass_name
    "templates/config/properties/#{name}".classify
  end

  # @!endgroup

  class << self
    # @param [Types::Templates::Kind] template_kind
    # @raise [FrozenRecord::RecordNotFound]
    # @return [TemplateEnumProperty]
    def background_for!(template_kind)
      backgrounds.find_by_formatted_name! template_kind, "background"
    end

    # @param [Types::Templates::Kind] template_kind
    # @raise [FrozenRecord::RecordNotFound]
    # @return [TemplateEnumProperty]
    def selection_mode_for!(template_kind)
      selection_modes.find_by_formatted_name! template_kind, "selection_mode"
    end

    # @param [Types::Templates::Kind] template_kind
    # @raise [FrozenRecord::RecordNotFound]
    # @return [TemplateEnumProperty]
    def variant_for!(template_kind)
      variants.find_by_formatted_name! template_kind, "variant"
    end

    # @api private
    # @param [Types::Templates::Kind] template_kind
    # @param ["background", "selection_mode", "variant"] suffix
    # @raise [FrozenRecord::RecordNotFound]
    # @return [TemplateEnumProperty]
    def find_by_formatted_name!(template_kind, suffix)
      name = "%<template_kind>s_%<suffix>s" % { template_kind:, suffix: }

      find_by! name:
    end
  end
end
