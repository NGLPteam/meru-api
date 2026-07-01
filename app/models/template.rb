# frozen_string_literal: true

class Template < ::ApplicationFrozenRecord
  include ActiveModel::Validations
  include Dry::Core::Equalizer.new(:template_kind)
  include Dry::Core::Memoizable

  schema!(types: ::Templates::TypeRegistry) do
    required(:template_kind).filled(:template_kind)
    required(:layout_kind).filled(:layout_kind)
    required(:description).maybe(:stripped_string)
    required(:has_announcements).value(:bool)
    required(:has_background).value(:bool)
    required(:has_contribution_list).value(:bool)
    required(:has_entity_list).value(:bool)
    required(:has_ordering_pair).value(:bool)
    required(:has_see_all_ordering).value(:bool)
    required(:has_variant).value(:bool)
    required(:root_tag).filled(:string)
  end

  default_attributes!(
    description: nil,
    has_announcements: false,
    has_background: true,
    has_contribution_list: false,
    has_entity_list: false,
    has_ordering_pair: false,
    has_see_all_ordering: false,
    has_variant: false,
  )

  calculates! :root_tag do |record|
    record["template_kind"].dasherize
  end

  TEMPLATING_ROOT = Rails.root.join("lib", "templating")

  self.primary_key = :template_kind

  add_index :template_kind, unique: true

  alias_attribute :kind, :template_kind

  delegate :definition_klass, :definition_table, :definition_type, :instance_klass, :instance_table, :instance_type, to: :layout, prefix: true

  validates :definition_klass, :instance_klass, presence: true

  validate :all_props_accounted_for!

  def has_width?
    properties.one?(&:width?)
  end

  def introspect
    slice(:template_kind, :description, :properties, :slots)
  end

  # @return [Layout]
  memoize def layout
    Layout.find layout_kind
  end

  # @return [<TemplateProperty>]
  memoize def properties
    TemplateProperty.for_template(template_kind).to_a
  end

  memoize def property_names
    properties.map(&:name)
  end

  memoize def property_names_for_configuration
    properties.reject(&:skip_configuration?).select(&:active?).map(&:name)
  end

  # @return [<TemplateSlot>]
  memoize def slots
    TemplateSlot.for_template(template_kind).to_a
  end

  memoize def slot_names
    slots.map(&:name)
  end

  # @!group Main Classes

  klass_name_pair! :definition, model: true do
    "templates/#{template_kind}_definition".classify
  end

  klass_name_pair! :instance, model: true do
    "templates/#{template_kind}_instance".classify
  end

  klass_name_pair! :gql_definition do
    "types/templates/#{template_kind}_template_definition_type".classify
  end

  klass_name_pair! :gql_instance do
    "types/templates/#{template_kind}_template_instance_type".classify
  end

  klass_name_pair! :slot_definition_mapping do
    "templates/slot_mappings/#{template_kind}_definition_slots".camelize(:upper)
  end

  klass_name_pair! :slot_instance_mapping do
    "templates/slot_mappings/#{template_kind}_instance_slots".camelize(:upper)
  end

  # @!endgroup

  # @!group Config

  klass_name_pair! :config do
    "templates/config/template/#{template_kind}".classify
  end

  klass_name_pair! :config_slots do
    "templates/config/template_slots/#{template_kind}_slots".camelize(:upper)
  end

  # @!endgroup

  # @!group Composition

  memoize def composition_root
    TEMPLATING_ROOT.join("compositions", template_kind)
  end

  def composition_configuration
    raw_content = composition_configuration_path.read

    ::Templates::Compositions::Configuration.from_xml(raw_content).tap do |config|
      config.template_kind = template_kind
    end
  end

  memoize def composition_configuration_path
    composition_root.join("config.xml")
  end

  # @return [Templates::Compositions::Configuration]
  def to_composition
    Templates::Compositions::Configuration.from_hash(to_composition_hash)
  end

  def to_composition_hash
    slice(
      :template_kind,
      :layout_kind,
      :description,
      :has_background,
      :has_variant
    ).merge(
      props: properties.map(&:to_composition_hash),
      slots: slots.map(&:to_composition_hash)
    ).stringify_keys
  end

  def to_composition_xml
    to_composition.to_xml(pretty: true, declaration: true, encoding: true)
  end

  # @return [void]
  def write_composition!
    composition_root.mkpath

    composition_configuration_path.open("wb+") do |f|
      f.write to_composition_xml
    end
  end

  # @!endgroup

  private

  # @return [void]
  def all_props_accounted_for!
    # simplecov:disable
    properties.each do |prop|
      next if prop.exists_on_definition?

      errors.add :base, "#{definition_klass} is missing property: #{prop.name}"
    end
    # simplecov:enable
  end

  class << self
    # @return [void]
    def write_compositions!
      each(&:write_composition!)
    end
  end
end
