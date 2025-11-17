# frozen_string_literal: true

module Types
  class LinkTargetCandidateType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id

    description "A candidate for a link target, scoped to a parent source"

    field :target, "Types::EntityType", null: false,
      description: "The actual target"

    field :target_id, ID, null: false,
      description: "The targetID to provide to linkEntity"

    field :kind, Types::LinkTargetCandidateKindType, null: false,
      method: :target_type

    field :title, String, null: false,
      description: "The target entity's title"

    field :depth, Integer, null: false,
      description: "How deeply nested the candidate entity is"

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def target_id
      object.target.to_encoded_id
    end
  end
end
