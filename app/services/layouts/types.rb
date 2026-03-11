# frozen_string_literal: true

module Layouts
  module Types
    extend ::Support::Typespace

    include Dry::Core::Constants

    Association = Coercible::Symbol

    Associations = Array.of(Association)

    Entity = Instance(::HierarchicalEntity)

    Generation = ::Rendering::Types::Generation

    Kind = LayoutKind = ApplicationRecord.dry_pg_enum(:layout_kind)

    LayoutDefinition = Instance(::LayoutDefinition)

    LayoutDefinitions = Coercible::Array.of(LayoutDefinition)

    LayoutDefinitionMapping = Hash.map(Kind, LayoutDefinitions)

    LayoutInstance = Instance(::LayoutInstance)

    LayoutInstances = Coercible::Array.of(LayoutInstance)

    TemplateMapping = ApplicationRecord.pg_enum_values(:layout_kind).index_with do |layout_kind|
      ApplicationRecord.pg_enum_values(:"#{layout_kind}_template_kind")
    end.with_indifferent_access.freeze

    TemplateLookup = TemplateMapping.each_with_object({}) do |(layout, templates), lookup|
      templates.each do |template|
        # :nocov:
        raise "duplicate template #{template} for #{layout}, already in #{lookup[template]}" if template.in?(lookup)
        # :nocov:

        lookup[template] = layout
      end
    end.with_indifferent_access.freeze
  end
end
