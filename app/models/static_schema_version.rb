# frozen_string_literal: true

# @see SchemaDefinition
# @see SchemaVersion
# @see StaticSchemaDefinition
class StaticSchemaVersion < ::ApplicationFrozenRecord
  include ActiveModel::Validations
  include Dry::Core::Equalizer.new(:declaration)
  include Dry::Core::Memoizable
  include StaticSchemaRecord

  schema!(types: ::Schemas::Static::TypeRegistry) do
    required(:declaration).filled(:version_declaration)
    required(:definition).filled(:definition_declaration)
    required(:namespace).filled(:namespace)
    required(:identifier).filled(:identifier)
    required(:number).filled(:version_number)
    required(:version).filled(:semantic_version)
    required(:root).filled(:pathname)
    required(:path).filled(:pathname)
    required(:config_path).filled(:pathname)
    required(:layouts_path).filled(:pathname)
    required(:testing).value(:bool)
    required(:configuration).value(:hash)
    required(:name).filled(:string)
    required(:kind).filled(:schema_kind)
    required(:layouts_map).value(:hash)
  end

  default_attributes!(
    testing: false,
  )

  calculates_id_from! :namespace, :identifier, :number, attr: :declaration, separator: ?:

  calculates_id_from! :namespace, :identifier, attr: :definition, separator: ?:

  calculates! :version do |record|
    ::Semantic::Version.new(record["number"])
  end

  calculates! :root do |record|
    ROOT.join(record.fetch("namespace"), record.fetch("identifier"))
  end

  calculates! :path do |record|
    record.fetch("root").join(record.fetch("number"))
  end

  calculates! :config_path do |record|
    record.fetch("path").join("config.json")
  end

  calculates! :layouts_path do |record|
    record.fetch("path").join("layouts")
  end

  calculates! :testing do |record|
    record["namespace"] == "testing"
  end

  calculates! :version do |record|
    ::Semantic::Version.new(record["number"])
  end

  calculates! :configuration do |record|
    JSON.parse(record.fetch("config_path").read).with_indifferent_access
  rescue Errno::ENOENT
    # :nocov:
    {}
    # :nocov:
  end

  calculates! :name do |record|
    record.fetch("configuration", {}).fetch(:name) do
      record.fetch("identifier", "Schema").titleize
    end
  end

  calculates! :kind do |record|
    record.fetch("configuration", {}).fetch(:kind)
  end

  calculates! :layouts_map do |record|
    layouts_path = record.fetch("layouts_path")

    ::Layout.build_config_map_for(layouts_path)
  end

  self.primary_key = :declaration

  add_index :declaration, unique: true
  add_index :definition

  # @return [SchemaVersion]
  def find_schema_version
    SchemaVersion[declaration]
  end

  # @param [Layouts::Types::Kind] layout_kind
  # @return [Templates::Config::Utility::AbstractLayout]
  def layout_config_for(layout_kind)
    layouts_map.fetch(layout_kind) do
      # :nocov:
      Layout.build_default_for(layout_kind)
      # :nocov:
    end
  end

  # @return [void]
  def export_layouts!
    # :nocov:
    schema_version = find_schema_version

    layouts = schema_version.root_layouts.transform_values(&:export!)

    layouts.each do |kind, config|
      layout_path = layouts_path.join("#{kind}.xml")

      layout_path.open("wb+") do |f|
        f.write config.to_xml(pretty: true, declaration: true, encoding: true)
      end
    end
    # :nocov:
  end

  class << self
    # @param [Schemas::Static::Types::VersionDeclaration] decl
    def [](decl)
      find_by!(declaration: decl.to_s)
    end

    # @return [void]
    def calculate_static_schema_definitions!
      # :nocov:
      declarations = pluck(:definition).uniq

      data = declarations.map do |definition|
        version = where(definition:).order(number: :desc).first!

        version.slice(:namespace, :identifier, :kind).stringify_keys
      end.sort do |a, b|
        (b["namespace"] <=> a["namespace"]).nonzero? || a["identifier"] <=> b["identifier"]
      end

      Rails.root.join("lib", "frozen_record", "static_schema_definitions.yml").open("wb+") do |f|
        f.write data.to_yaml
      end
      # :nocov:
    end
  end
end
