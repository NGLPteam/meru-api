# frozen_string_literal: true

# @see SchemaDefinition
# @see StaticSchemaVersion
class StaticSchemaDefinition < ::ApplicationFrozenRecord
  include ActiveModel::Validations
  include Dry::Core::Equalizer.new(:declaration)
  include Dry::Core::Memoizable
  include StaticSchemaRecord

  schema!(types: ::Schemas::Static::TypeRegistry) do
    required(:declaration).filled(:definition_declaration)
    required(:namespace).filled(:namespace)
    required(:identifier).filled(:identifier)
    required(:root).filled(:pathname)
    required(:development).value(:bool)
    required(:testing).value(:bool)
    required(:name).filled(:string)
    required(:versions).value(:array)
    required(:kind).value(:schema_kind)
    required(:installable).value(:bool)
    optional(:latest).value(:any)
  end

  default_attributes!(
    development: false,
    testing: false,
  )

  calculates_id_from! :namespace, :identifier, attr: :declaration, separator: ?:

  calculates! :root do |record|
    ROOT.join(record["namespace"], record["identifier"])
  end

  calculates! :testing do |record|
    record["namespace"] == "testing"
  end

  calculates! :versions do |record|
    definition = record.fetch("declaration")

    StaticSchemaVersion.where(definition:).to_a.sort_by(&:version).reverse
  end

  calculates! :latest do |record|
    record.fetch("versions").first
  end

  calculates! :name do |record|
    record.fetch("latest")&.name || record.fetch("identifier").titleize
  end

  calculates! :installable do |record|
    next false if record["testing"] && !MeruConfig.include_testing_schemas?
    next false if record["development"] && !MeruConfig.include_development_schemas?

    true
  end

  self.primary_key = :declaration

  add_index :declaration, unique: true

  scope :installable, -> { where(installable: true) }

  class << self
    # @param [Schemas::Static::Types::DefinitionDeclaration] decl
    def [](decl)
      find_by!(declaration: decl.to_s)
    end
  end
end
