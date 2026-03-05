# frozen_string_literal: true

module Resolvers
  # A resolver of {Ordering orderings} for a {SchemaInstance}.
  #
  # @see ::Types::EntityType
  # @see ::Types::OrderingType
  class OrderingResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsOrdering

    description <<~TEXT
    Retrieve a connection of orderings for the parent object.
    TEXT

    type ::Types::OrderingType.connection_type, null: false

    resolves_model! ::Ordering, must_have_object: true

    option :availability, type: ::Types::OrderingAvailabilityFilterType, default: "ALL",
      description: "Optionally filter orderings by whether they are enabled or disabled."

    option :visibility, type: ::Types::OrderingVisibilityFilterType, default: "ALL",
      description: "Optionally filter orderings by whether they are visible or hidden."

    # @!group Availability Handlers

    # @param [ActiveRecord::Relation<Ordering>] scope
    # @return [ActiveRecord::Relation<Ordering>]
    def apply_availability_with_all(scope)
      scope.all
    end

    # @param [ActiveRecord::Relation<Ordering>] scope
    # @return [ActiveRecord::Relation<Ordering>]
    def apply_availability_with_enabled(scope)
      scope.enabled
    end

    # @param [ActiveRecord::Relation<Ordering>] scope
    # @return [ActiveRecord::Relation<Ordering>]
    def apply_availability_with_disabled(scope)
      scope.disabled
    end

    # @!endgroup

    # @!group Visibility Handlers

    # @param [ActiveRecord::Relation<Ordering>] scope
    # @return [ActiveRecord::Relation<Ordering>]
    def apply_visibility_with_all(scope)
      scope.all
    end

    # @param [ActiveRecord::Relation<Ordering>] scope
    # @return [ActiveRecord::Relation<Ordering>]
    def apply_visibility_with_visible(scope)
      scope.visible
    end

    # @param [ActiveRecord::Relation<Ordering>] scope
    # @return [ActiveRecord::Relation<Ordering>]
    def apply_visibility_with_hidden(scope)
      scope.hidden
    end

    # @!endgroup
  end
end
