# frozen_string_literal: true

# A frozen record describing each possible type that a schema property can have.
class SchemaPropertyType < ::ApplicationFrozenRecord
  include Dry::Core::Constants
  include Dry::Core::Equalizer.new(:name)
  include Dry::Core::Memoizable

  schema!(types: ::Schemas::System::TypeRegistry) do
    required(:name).value(:type_name)
    required(:array).value(:bool)

    # kind derivations
    required(:model_klass_names).array(:string)
    required(:complex).value(:bool)
    required(:reference).value(:bool)

    required(:orderable).value(:bool)
    required(:searchable).value(:bool)

    required(:kind_name).value(:kind_name)
  end

  self.primary_key = :name

  add_index :name, unique: true
  add_index :kind_name

  default_attributes!(
    array: false,
    orderable: false,
    searchable: false,
  )

  calculates! :model_klass_names do |record|
    case record["name"]
    in /\Aasset/i
      %w[Asset]
    in /\Acontrib/
      %w[Contributor]
    in /\Acontrolled_vocab/i
      %w[ControlledVocabularyItem]
    in /\Aentit/
      %w[Community Collection Item]
    else
      EMPTY_ARRAY
    end
  end

  calculates! :reference do |record|
    record["model_klass_names"].present?
  end

  calculates! :complex do |record|
    record["reference"]
  end

  calculates! :kind_name do |record|
    if record["name"] == "group"
      "group"
    elsif record["reference"]
      "reference"
    elsif record["complex"]
      "complex"
    else
      "simple"
    end
  end

  def group?
    kind_name == "group"
  end

  klass_name_pair! :definition do
    if group?
      "::Schemas::Properties::GroupDefinition"
    else
      "schemas/properties/scalar/#{name}".camelize(:upper)
    end
  end
end
