# frozen_string_literal: true

module Mutations
  module Operations
    class AlterSchemaVersion
      include MutationOperations::Base
      include Mutations::Shared::WithSchemaErrors
      include Mutations::Shared::AssignsSchemaVersion
      include Mutations::Shared::AttachesPolymorphicEntity
      include Mutations::Shared::ForceRendersLayouts
      include Mutations::Shared::RefreshesOrderingsAsynchronously
      include MeruAPI::Deps[alter: "schemas.instances.alter_version"]

      authorizes! :entity, with: :alter_schema_version?
      authorizes! :entity, with: :update?

      use_contract! :alter_schema_version

      def call(entity:, property_values:, strategy: :apply, **)
        alteration = alter.call(entity, loaded_schema_version, property_values, strategy:)

        with_applied_schema_values! alteration do |applied_entity|
          attach_polymorphic_entity! applied_entity

          force_render_layouts_for! applied_entity
        end
      end
    end
  end
end
