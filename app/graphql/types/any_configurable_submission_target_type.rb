# frozen_string_literal: true

module Types
  # @see Mutations::SubmissionTargetConfigure
  class AnyConfigurableSubmissionTargetType < Types::BaseUnion
    description <<~TEXT
    An input for `submissionTargetConfigure` that accepts a submission target
    **or** an entity that can be configured.
    TEXT

    possible_types(
      Types::CommunityType,
      Types::CollectionType,
      Types::ItemType,
      Types::SubmissionTargetType
    )

    class << self
      def resolve_type(object, _context) = object.graphql_node_type
    end
  end
end
