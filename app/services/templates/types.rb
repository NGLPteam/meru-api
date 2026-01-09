# frozen_string_literal: true

module Templates
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    Asset = ModelInstance("Asset")

    Assigns = Hash.map(Coercible::String, Any)

    CachedEntityList = ModelInstance("Templates::CachedEntityList")

    Contribution = Instance(::Contribution)

    Contributions = Coercible::Array.of(Contribution)

    ContributorListFilter = ApplicationRecord.dry_pg_enum("contributor_list_filter", default: "all").fallback("all")

    EnumPropertyCategory = Coercible::String.default("none").enum(
      "background",
      "none",
      "selection_mode",
      "variant",
    ).fallback("none")

    EnumPropertyName = Coercible::String.enum(
      "blurb_background",
      "contributor_list_background",
      "contributor_list_filter",
      "descendant_list_background",
      "descendant_list_selection_mode",
      "descendant_list_variant",
      "detail_background",
      "detail_variant",
      "hero_background",
      "link_list_background",
      "link_list_selection_mode",
      "link_list_variant",
      "list_entity_context",
      "list_item_selection_mode",
      "metadata_background",
      "navigation_background",
      "ordering_background",
      "page_list_background",
      "selection_source_mode",
      "supplementary_background",
      "template_width"
    )

    DescendantListSelectionMode = ApplicationRecord.dry_pg_enum(:descendant_list_ordering_mode)

    Entity = Instance(::HierarchicalEntity)

    Entities = Coercible::Array.of(Entity)

    Generation = ::Rendering::Types::Generation

    Kind = TemplateKind = ApplicationRecord.dry_pg_enum(:template_kind)

    Kinds = Array.of(Kind)

    LayoutDefinition = Instance(::LayoutDefinition)

    LayoutInstance = Instance(::LayoutInstance)

    LayoutKind = ApplicationRecord.dry_pg_enum(:layout_kind)

    LIMIT_DEFAULT = 3

    LIMIT_MIN = 1

    LIMIT_MAX = 40

    LIMIT_RANGE = LIMIT_MIN..LIMIT_MAX

    LIMIT_CONSTRAINTS = { included_in: LIMIT_RANGE, gteq: LIMIT_MIN, lteq: LIMIT_MAX }.freeze

    Limit = Coercible::Integer.default(LIMIT_DEFAULT).constrained(**LIMIT_CONSTRAINTS)

    LimitWithFallback = Limit.fallback(LIMIT_DEFAULT)

    LinkListSelectionMode = ApplicationRecord.dry_pg_enum(:link_list_ordering_mode)

    ManualListSource = Instance(::ManualListSource)

    ManualListTarget = Instance(::ManualListTarget)

    ManualListTargets = Coercible::Array.of(ManualListTarget)

    OrderingDefinition = Instance(::Schemas::Orderings::Definition).constructor do |value|
      case value
      when ::Schemas::Orderings::Definition then value
      when ::Hash
        ::Schemas::Orderings::Definition.new(value)
      when nil, Dry::Core::Constants::Undefined
        ::Schemas::Orderings::Definition.new
      else
        raise Dry::Types::CoercionError, "invalid ordering definition input: #{value.inspect}"
      end
    end

    RESERVED_PROPERTY_NAMES = %w[
      layout_definition_id
      layout
      layout_kind
      created_at
      updated_at
      config
      position
      slots
      template
      template_kind
    ].freeze

    PropertyKind = Coercible::String.enum(
      "background",
      "boolean",
      "contributor_list_filter",
      "limit",
      "list_entity_context",
      "ordering_definition",
      "schema_component",
      "schema_property_path",
      "selection_mode",
      "selection_source",
      "selection_source_mode",
      "string",
      "variant",
      "width"
    )

    PropertyName = Coercible::String.constrained(excluded_from: RESERVED_PROPERTY_NAMES)

    SchemaComponent = ::Schemas::Types::Component

    SchemaVersion = ModelInstance("SchemaVersion")

    SELECTION_SOURCE_SELF_PATTERN = /\Aself\z/

    SELECTION_SOURCE_PARENT_PATTERN = /\Aparent\z/

    SELECTION_SOURCE_ANCESTOR_PATTERN = /
    ancestors
    \.
    (?<ancestor_name>[a-z][a-z0-9_]*[a-z])
    /x

    SelectionSourceSelf = Coercible::String.constrained(eql: "self")

    SelectionSourceParent = Coercible::String.constrained(eql: "parent")

    SelectionSourceAncestor = Coercible::String.constrained(format: SELECTION_SOURCE_ANCESTOR_PATTERN)

    SELECTION_SOURCE_PATTERN = /\A
    (?:#{SELECTION_SOURCE_SELF_PATTERN})
    |
    (?:#{SELECTION_SOURCE_PARENT_PATTERN})
    |
    (?:#{SELECTION_SOURCE_ANCESTOR_PATTERN})
    \z
    /x

    SelectionSource = Coercible::String.default("self").constrained(format: SELECTION_SOURCE_PATTERN)

    SelectionSourceMode = ApplicationRecord.dry_pg_enum(:selection_source_mode, default: "self").fallback("self")

    SlotKind = ::Types::TemplateSlotKindType.dry_type

    SlotScope = Coercible::String.default("abstract").enum("abstract", "definition", "instance").fallback("abstract")

    StrippedString = Coercible::String.constructor { _1.to_s.strip_heredoc.strip }

    TemplateDefinition = Instance(::TemplateDefinition)

    TemplateInstance = Instance(::TemplateInstance)

    TemplateWidth = ApplicationRecord.dry_pg_enum("template_width", default: "full").fallback("full")
  end
end
