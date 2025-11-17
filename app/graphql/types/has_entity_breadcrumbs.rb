# frozen_string_literal: true

module Types
  # Exposes a `breadcrumbs` property for any type that implements this.
  module HasEntityBreadcrumbs
    include Types::BaseInterface

    field :breadcrumbs, [Types::EntityBreadcrumbType, { null: false }], null: false do
      description "Previous entries in the hierarchy"
    end

    load_association! :entity_breadcrumbs, as: :breadcrumbs
  end
end
