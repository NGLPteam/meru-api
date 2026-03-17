# frozen_string_literal: true

module Schemas
  module Orderings
    module Types
      extend ::Support::Typespace

      COMPONENT_FORMAT = /[a-z][a-z0-9_]*?[a-z0-9]/

      ANCESTOR_NAME = /\A#{COMPONENT_FORMAT}\z/

      AncestorName = Coercible::String.constrained(format: ANCESTOR_NAME)

      ArelJoin = Instance(::Arel::Nodes::Join)

      ArelJoinMap = Hash.map(String, ArelJoin)

      ArelJoins = Array.of(ArelJoin)

      ArelOrdering = Instance(::Arel::Nodes::Ordering)

      ArelOrderings = Array.of(ArelOrdering)

      ArelPropsMap = Hash.map(String, Instance(::Arel::Expressions))

      ColumnList = Coercible::Array.of(Coercible::Symbol).constrained(min_size: 1)

      Direction = ::Support::GlobalTypes::SimpleSortDirection

      OrderBuilderName = Coercible::String.enum(
        "by_columns",
        "by_is_link",
        "by_schema_property",
        "by_variable_date",
      )

      OrderingFilter = Instance(Schemas::Associations::OrderingFilter).constructor do |value|
        case value
        when Schemas::Associations::OrderingFilter then value
        when OrderingFilterOptions
          Schemas::Associations::OrderingFilter.new(value)
        else
          value
        end
      end

      OrderingFilterOptions = Hash.schema({
        namespace: String,
        identifier: String,
        version?: String
      }).with_key_transform(&:to_sym)

      OrderingFilters = Array.of(OrderingFilter)

      RefreshMode = Coercible::String.default("sync").enum("sync", "async", "disabled")

      RenderMode = Coercible::String.default("flat").enum("flat", "tree").fallback("flat")

      SelectDirect = Coercible::String.default("children").enum("none", "children", "descendants").fallback("none")

      SUPPORTED_STATIC_PROP_TYPES = %w[string variable_date integer timestamp boolean select].freeze

      StaticPropertyType = Coercible::String.default("string").enum(*SUPPORTED_STATIC_PROP_TYPES)
    end
  end
end
