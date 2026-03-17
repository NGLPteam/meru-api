# frozen_string_literal: true

module Schemas
  module References
    # @api private
    # @see Schemas::Instances::PropertiesApplicator
    # @see SchematicCollectedReference
    # @note Non-monadic operation.
    class WriteCollectedReferences
      UNIQUE_BY = %i[referrer_type referrer_id referent_type referent_id path].freeze

      # @param [HasSchemaDefinition] referrer
      # @param [String] path
      # @param [<ApplicationRecord>] referents
      # @return [void]
      def call(referrer, path, referents)
        clear_missing! referrer, path, referents

        upsert! referrer, path, referents if referents.any?
      end

      private

      # @return [void]
      def clear_missing!(referrer, path, referents)
        scope = referrer.schematic_collected_references.by_path(path)

        scope = scope.where.not(referent: referents) if referents.present?

        scope.delete_all
      end

      # @return [void]
      def upsert!(referrer, path, referents)
        base_columns = {
          referrer_type: referrer.model_name.to_s,
          referrer_id: referrer.id,
          path:
        }

        attributes = referents.map.with_index do |referent, i|
          position = i + 1

          base_columns.merge(
            referent_type: referent.model_name.to_s,
            referent_id: referent.id,
            position:
          )
        end

        SchematicCollectedReference.upsert_all(attributes, unique_by: UNIQUE_BY)
      end
    end
  end
end
