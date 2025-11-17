# frozen_string_literal: true

module Types
  module QueriesContrib
    include Types::BaseInterface

    description <<~TEXT
    Fields for querying details about contributors and contributions.
    TEXT

    field :collection_contribution, Types::CollectionContributionType, null: true do
      description "Look up a collection contribution by slug"

      argument :slug, Types::SlugType, required: true
    end

    field :contributor, Types::ContributorType, null: true do
      description "Look up a contributor by slug"

      argument :slug, Types::SlugType, required: true
    end

    field :contributor_lookup, Types::ContributorType, null: true do
      description <<~TEXT
      Look up a contributor `by` a certain `value`.
      TEXT

      argument :by, Types::ContributorLookupFieldType, required: true, as: :field do
        description <<~TEXT
        The field to search a contributor with. Unless otherwise specified, the provided
        `value` will be an exact match.
        TEXT
      end

      argument :value, String, required: true do
        description <<~TEXT
        The actual value to look a contributor up `by`.
        TEXT
      end

      argument :order, Types::SimpleOrderType, required: true, default_value: "RECENT" do
        description <<~TEXT
        For certain fields, the values are not guaranteed to be unique. In these instances,
        the *most recently* created contributor will be selected by default. If the first
        is preferred, specify `order: OLDEST`.
        TEXT
      end
    end

    field :contribution_roles, Types::ContributionRoleConfigurationType, null: false do
      description "Look up contribution role configuration for a given contributable (or globally)."

      argument :contributable_id, ID, loads: Types::ContributableType, required: false do
        description "The contributable to load for, if applicable."
      end
    end

    field :contributors, resolver: Resolvers::ContributorResolver do
      description "A list of all contributors in the system"
    end

    field :item_contribution, Types::ItemContributionType, null: true do
      description "Look up an item contribution by slug"

      argument :slug, Types::SlugType, required: true
    end

    def collection_contribution(slug:)
      load_record_with(::CollectionContribution, slug)
    end

    # @param [Contributable, nil] contributable
    # @return [ContributionRoleConfiguration]
    def contribution_roles(contributable: nil)
      call_operation("contribution_roles.fetch_config", contributable:).value_or(nil)
    end

    def contributor(slug:)
      load_record_with(::Contributor, slug)
    end

    def contributor_lookup(**options)
      call_operation "contributors.lookup", **options do |m|
        m.success do |mapped_options|
          mapped_options => { value:, find_by:, }

          load_record_with(::Contributor, value, find_by:)
        end

        m.failure(:invalid) do |_, reason|
          raise GraphQL::ExecutionError, "An error occurred when looking up a contributor: #{reason}"
        end

        m.failure do
          # :nocov:
          raise GraphQL::ExecutionError, "Something went wrong with contributor lookup"
          # :nocov:
        end
      end
    end

    def item_contribution(slug:)
      load_record_with(::ItemContribution, slug)
    end
  end
end
