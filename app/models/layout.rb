# frozen_string_literal: true

class Layout < ::ApplicationFrozenRecord
  include ActiveModel::Validations
  include Dry::Core::Equalizer.new(:layout_kind)
  include Dry::Core::Memoizable

  schema!(types: ::Templates::TypeRegistry) do
    required(:layout_kind).filled(:layout_kind)
    required(:template_kinds).filled(:template_kinds)
    required(:default_templates).value(:template_kinds)
    required(:description).maybe(:stripped_string)
    required(:root_tag).filled(:string)
    required(:single_template).value(:bool)
    required(:template_kinds_count).value(:integer)
    required(:enum_name).filled(:string)
    required(:file_name).filled(:string)
  end

  default_attributes!(
    description: nil
  )

  calculates_format! :enum_name, "%<layout_kind>s_template_kind"
  calculates_format! :file_name, "%<layout_kind>s.xml"

  calculates! :template_kinds do |record|
    ApplicationRecord.pg_enum_values(record.fetch("enum_name")).freeze
  end

  calculates! :root_tag do |record|
    record["layout_kind"].dasherize
  end

  calculates! :single_template do |record|
    record["template_kinds"].one?
  end

  calculates! :template_kinds_count do |record|
    record["template_kinds"].size
  end

  calculates! :default_templates do |record|
    record["template_kinds"].then { _1.take(1).freeze }
  end

  self.primary_key = :layout_kind

  add_index :layout_kind, unique: true

  alias_attribute :kind, :layout_kind

  validates :definition_klass, :instance_klass, :template_kinds, presence: true

  validates :templates, length: {
    is: :template_kinds_count,
    wrong_length: "has the wrong number of templates (should be %{count})",
  }

  def introspect
    slice(:layout_kind, :description).merge(templates: templates.map(&:introspect))
  end

  # @return [Templates::Config::Utility::AbstractLayout]
  def build_default
    config_klass.build_default
  end

  # @return [<Template>]
  memoize def templates
    Template.where(layout_kind:).to_a
  end

  # @!group Main Classes

  klass_name_pair! :definition, model: true do
    "layouts/#{layout_kind}_definition".classify
  end

  klass_name_pair! :instance, model: true do
    "layouts/#{layout_kind}_instance".classify
  end

  klass_name_pair! :gql_definition do
    "types/layouts/#{layout_kind}_layout_definition_type".classify
  end

  klass_name_pair! :gql_instance do
    "types/layouts/#{layout_kind}_layout_instance_type".classify
  end

  # @!endgroup

  # @!group Config

  klass_name_pair! :config do
    "templates/config/layout/#{layout_kind}".classify
  end

  klass_name_pair! :config_templates do
    "templates/config/layout_templates/#{layout_kind}_templates".camelize(:upper)
  end

  # @!endgroup

  # @api private
  # @see .build_config_map_for
  # @param [Pathname] layouts_path
  # @return [Templates::Config::Utility::AbstractLayout]
  def build_config_for(layouts_path)
    config_path = layouts_path.join(file_name)

    raw_config = config_path.read

    config_klass.from_xml(raw_config)
  rescue Errno::ENOENT
    build_default
  end

  class << self
    # @see #build_config_for
    # @param [Pathname] layouts_path
    # @return [{ Layouts::Types::Kind => Templates::Config::Utility::AbstractLayout }]
    def build_config_map_for(layouts_path)
      all.each_with_object({}.with_indifferent_access) do |layout, map|
        map[layout.layout_kind] = layout.build_config_for(layouts_path)
      end
    end

    # @param [Layouts::Types::Kind] layout_kind
    # @return [Templates::Config::Utility::AbstractLayout]
    def build_default_for(layout_kind)
      layout = find layout_kind.to_s

      layout.build_default
    end

    # @return [{ Symbol => Regexp }]
    def constraints
      @constraints ||= {}.tap do |c|
        c[:layout_kind] = Regexp.union(pluck(:layout_kind))
      end.freeze
    end
  end
end
