# frozen_string_literal: true

module Harvesting
  module Entities
    # @see Harvesting::Entities::PruneEntities
    class EntitiesPruner < Harvesting::Utility::AbstractEntitiesPruner
      include Dry::Effects::Handler.Interrupt(:skip_prune, as: :catch_skip_prune)
      include Dry::Effects.Interrupt(:skip_prune)

      param :harvest_entity, Types::Entity

      delegate :harvest_record, to: :harvest_entity

      delegate :harvest_source, to: :harvest_record

      delegate :entity, to: :harvest_entity, prefix: :actual

      delegate :harvest_modification_status, to: :actual_entity, allow_nil: true

      around_execute :provide_harvest_source!
      around_execute :provide_harvest_record!
      around_execute :catch_skip_prune!

      # @return [String]
      attr_reader :entity_tag

      def prepare
        @entity_tag = "entity:#{harvest_entity.identifier}"

        super
      end

      def prune
        harvest_entity.children.map do |child|
          counts = yield child.prune_entities(mode:)

          absorb!(**counts)
        end

        if preserve_current?
          return skip_prune("did not prune because entity has been modified")
        elsif preserve_because_children?
          return skip_prune("did not prune because entity still has children")
        end

        yield destroy_actual!

        yield destroy_harvest_entity!

        @pruned += 1

        super
      end

      wrapped_hook! def destroy_actual
        # simplecov:disable
        if actual_entity.blank?
          logger.trace("no harvested entity to remove", tags: [entity_tag])

          return super
        end

        actual_entity.destroy

        unless actual_entity.destroyed?
          logger.error("could not destroy entity: #{actual_entity.class}.find(#{actual_entity.id.inspect})", tags: [entity_tag, "prune_failure"])

          return skip_prune("did not prune because entity still exists")
        end
        # simplecov:enable

        super
      end

      wrapped_hook! def destroy_harvest_entity
        harvest_entity.destroy!

        super
      end

      private

      # @return [void]
      def catch_skip_prune!
        skipped, result = catch_skip_prune do
          yield
        end

        return unless skipped

        message =
          case result
          when String then result
          else
            # simplecov:disable
            "skipped for unknown reason"
            # simplecov:enable
          end

        @skipped += 1

        logger.debug(message, tags: ["skipped_prune", entity_tag])

        return
      end

      def preserve_because_children?
        harvest_entity.children.exists?
      end

      def preserve_current?
        # simplecov:disable
        return false if actual_entity.blank?
        # simplecov:enable

        preserve_modifications? && harvest_modification_status != "pristine"
      end
    end
  end
end
