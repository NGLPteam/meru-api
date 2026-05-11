# frozen_string_literal: true

class TemplatePropertyKind < ::ApplicationFrozenRecord
  include Dry::Core::Equalizer.new(:name)

  schema!(types: ::Templates::TypeRegistry) do
    required(:name).filled(:property_kind)
    required(:enum_category).maybe(:enum_property_category)
    required(:enum_name).maybe(:enum_property_name)
    required(:any_enum).value(:bool)
    required(:dry_type_key).maybe(:string)
    required(:gql_type_name).maybe(:string)
  end

  default_attributes!(
    enum_category: nil,
    enum_name: nil,
    dry_type_key: nil,
    gql_type_name: nil,
  )

  self.primary_key = :name

  add_index :name, unique: true
  add_index :any_enum

  calculates! :any_enum do |record|
    record["enum_category"].present? || record["enum_name"].present?
  end

  scope :any_enum, -> { where(any_enum: true) }
  scope :non_enum, -> { where(any_enum: false) }
  scope :with_enum_category, -> { where.not(enum_category: nil) }

  # @param [Templates::Types::Kind] template_kind
  # @return [Dry::Types::Type]
  def dry_type_for(template_kind)
    if any_enum?
      enum_property_for(template_kind).dry_type
    else
      Templates::TypeRegistry[dry_type_key]
    end
  end

  # @param [Templates::Types::Kind] template_kind
  # @return [TemplateEnumProperty]
  def enum_property_for(template_kind)
    if enum_category?
      categorized_enum_property_for(template_kind)
    elsif enum_name?
      TemplateEnumProperty.find enum_name
    end
  end

  # @param [Templates::Types::Kind] template_kind
  # @return [String]
  def gql_type_name_for(template_kind)
    if any_enum?
      enum_property_for(template_kind).gql_type_full_klass_name
    else
      gql_type_name
    end
  end

  def shale_mapper_type_klass_name_for(template_kind)
    if any_enum?
      enum_property_for(template_kind).shale_mapper_type_klass_name
    else
      "templates/config/properties/#{name}".classify
    end
  end

  private

  # @param [Templates::Types::Kind] template_kind
  def categorized_enum_property_for(template_kind)
    # :nocov:
    case enum_category
    in "background"
      TemplateEnumProperty.background_for! template_kind
    in "selection_mode"
      TemplateEnumProperty.selection_mode_for! template_kind
    in "variant"
      TemplateEnumProperty.variant_for! template_kind
    end
    # :nocov:
  end
end
