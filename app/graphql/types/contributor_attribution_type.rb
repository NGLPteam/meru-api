# frozen_string_literal: true

module Types
  # @see ContributorAttribution
  # @see Types::AttributionType
  # @see Types::ContributorCollectionType
  # @see Types::ContributorITemType
  module ContributorAttributionType
    include Types::BaseInterface

    CONNECTION_AND_EDGE = {
      connection_klass_name: "Types::ContributorAttributionConnectionType",
      edge_klass_name: "Types::ContributorAttributionEdgeType",
    }.freeze

    use_direct_connection_and_edge!(**CONNECTION_AND_EDGE)

    description <<~TEXT
    Similar to `Attribution`, but from the perspective of a `Contributor`.
    TEXT

    field :entity_slug, Support::GQL::SlugType, null: false do
      description <<~TEXT
      The slug for the entity.
      TEXT
    end

    field :kind, Types::ChildEntityKindType, null: false do
      description <<~TEXT
      Whether this belongs to an item or a collection.
      TEXT
    end

    field :roles, [Types::ControlledVocabularyItemType, { null: false }], null: false do
      description <<~TEXT
      A priority-ordered list of the roles the associated contributor had.
      TEXT
    end

    field :published, Types::VariablePrecisionDateType, null: true do
      description <<~TEXT
      The published date, expressed as a variable precision date (if available).
      TEXT
    end

    field :published_on, GraphQL::Types::ISO8601Date, null: true do
      description <<~TEXT
      The published date, expressed as an ISO8601 date (if available).
      TEXT
    end

    field :title, String, null: false do
      description <<~TEXT
      The title of the entity.
      TEXT
    end

    def entity_slug
      object.entity_id
    end

    class << self
      def included(child_class)
        super

        return unless child_class < GraphQL::Schema::Object

        child_class.use_direct_connection_and_edge!(**CONNECTION_AND_EDGE)
      end
    end
  end
end
