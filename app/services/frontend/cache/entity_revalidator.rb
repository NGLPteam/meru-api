# frozen_string_literal: true

module Frontend
  module Cache
    # A service that talks to the Meru frontend in order to revalidate
    # its cache for a certain entity.
    #
    # @see Frontend::Cache::RevalidateEntity
    class EntityRevalidator < AbstractRevalidator
      param :entity, Frontend::Types::Entity

      kind "entity"

      uri_path! "/api/revalidate/entity"

      delegate :entity_kind, :entity_type, :system_slug, to: :entity
      delegate :id, to: :entity, prefix: true

      after_record_revalidation :revalidate_parent!

      private

      def build_attrs
        super.merge(
          entity_type:,
          entity_id:
        )
      end

      def build_params
        super.merge(
          type: entity_kind.to_s,
          slug: system_slug
        )
      end

      # @return [void]
      def revalidate_parent!
        entity.contextual_parent.then do |parent|
          # :nocov:
          Entities::RevalidateFrontendCacheJob.perform_later(parent) if parent.present?
          # :nocov:
        end
      end
    end
  end
end
