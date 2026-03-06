# frozen_string_literal: true

module Entities
  # Validate the attributes to upsert an {Entity}
  #
  # @see Entities:Sync
  class ValidateSync < ApplicationContract
    json do
      required(:auth_path).filled(Entities::Types::AuthPath)
      required(:entity_id).filled(:string, :uuid_v4?)
      required(:entity_type).filled(Entities::Types::EntityType)
      required(:hierarchical_id).filled(:string, :uuid_v4?)
      required(:hierarchical_type).filled(Entities::Types::HierarchicalType)
      optional(:link_operator).maybe(Links::Types::Operator)
      optional(:properties).value(:hash)
      required(:scope).filled(Entities::Types::Scope)
      required(:search_title).filled(:string)
      required(:schema_version_id).filled(:string, :uuid_v4?)
      required(:system_slug).filled(Entities::Types::Slug)
      required(:title).filled(:string)
      required(:submission_status).value(:entity_submission_status)

      required(:created_at).value(:time)
      required(:updated_at).value(:time)
    end
  end
end
