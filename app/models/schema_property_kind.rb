# frozen_string_literal: true

# A frozen record representing each kind that a {SchemaPropertyKind} can be.
#
# * Most properties are `simple`.
# * Properties that reference other records are a `reference`.
# * Properties that are not easily represented by a single value are `complex`.
# * `group`-type properties have the `group` kind and represent a special case,
#   being a property that contains nested properties. There is only one level
#   of nesting allowed.
class SchemaPropertyKind < ::ApplicationFrozenRecord
  include Dry::Core::Equalizer.new(:name)
  include Dry::Core::Memoizable

  schema!(types: ::Schemas::System::TypeRegistry) do
    required(:name).value(:kind_name)
  end

  self.primary_key = :name

  add_index :name, unique: true
end
