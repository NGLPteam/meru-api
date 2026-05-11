# frozen_string_literal: true

class TemplateProperty < ::ApplicationFrozenRecord
  include Templates::Config::SourcedByTemplateKind

  schema!(types: ::Templates::TypeRegistry) do
    required(:id).filled(:string)
    required(:template_kind).filled(:template_kind)
    required(:name).filled(:property_name)
    required(:property_kind_name).filled(:property_kind)
    required(:property_kind).value(Templates::Types.Instance(::TemplatePropertyKind))
    required(:description).maybe(:stripped_string)
    required(:default).maybe(:any)
    required(:skip_configuration).value(:bool)
    required(:skip_declaration).value(:bool)
    required(:deprecation_reason).maybe(:stripped_string)
    required(:deprecated).value(:bool)
    required(:active).value(:bool)
  end

  default_attributes!(
    default: nil,
    deprecation_reason: nil,
    skip_configuration: false,
    skip_declaration: false,
  )

  multiline! :deprecation_reason

  calculates! :description do |record|
    template_kind = record.fetch("template_kind")

    name = record.fetch("name")

    ::TemplateProperty.i18n_lookup_for(template_kind, name, :description)
  end

  calculates! :property_kind do |record|
    ::TemplatePropertyKind.find(record.fetch("property_kind_name"))
  end

  calculates! :deprecated do |record|
    record["deprecation_reason"].present?
  end

  calculates! :active do |record|
    record["deprecated"].blank?
  end

  self.primary_key = :id

  alias_attribute :kind, :property_kind_name

  delegate :any_enum?, to: :property_kind
  delegate :definition_klass, :definition_klass_name,
    :instance_klass, :instance_klass_name,
    to: :template

  scope :active, -> { where(active: true) }
  scope :deprecated, -> { where(deprecated: true) }

  def has_default?
    !default.nil?
  end

  memoize def dry_type
    property_kind.dry_type_for(template_kind)
  end

  # @return [TemplateEnumProperty, nil]
  memoize def enum_property
    property_kind.enum_property_for(template_kind)
  end

  memoize def gql_type_name
    property_kind.gql_type_name_for(template_kind)
  end

  def ordering_definition?
    property_kind_name == "ordering_definition"
  end

  klass_name_pair! :shale_mapper_type do
    property_kind.shale_mapper_type_klass_name_for(template_kind)
  end

  def exists_on_definition?
    name.in? definition_klass.column_names
  end

  # @return [Templates::Compositions::TemplateProperty]
  def to_composition
    Templates::Compositions::TemplateProperty.from_hash(to_composition_hash)
  end

  def to_composition_hash
    slice(
      :name,
      :kind,
      :description,
      :default
    ).stringify_keys
  end

  def width?
    name == "width" && property_kind_name == "width"
  end

  class << self
    # @param [Templates::Types::Kind] template_kind
    # @param [Templates::Types::PropertyName] property_name
    # @param [String] attr_name
    # @return [String, nil]
    def i18n_lookup_for(template_kind, property_name, attr_name)
      scope = "template_properties"

      default = [
        :"_common.#{property_name}.#{attr_name}",
        ""
      ]

      key = :"#{template_kind}.#{property_name}.#{attr_name}"

      I18n.t(key, scope:, default:, raise: false).strip.presence
    end
  end
end
