# frozen_string_literal: true

module Schemas
  module References
    # @api private
    # @see Schemas::Instances::PropertiesApplicator
    # @see SchematicScalarReference
    # @note Non-monadic operation.
    class WriteScalarReference
      UNIQUE_BY = %i[referrer_type referrer_id path].freeze

      # @param [HasSchemaDefinition] referrer
      # @param [String] path
      # @param [ApplicationRecord, nil] referents
      # @return [void]
      def call(referrer, path, referent)
        if referent.present?
          upsert! referrer, path, referent
        else
          clear! referrer, path
        end

        return
      end

      private

      # @param [HasSchemaDefinition] referrer
      # @param [String] path
      # @return [void]
      def clear!(referrer, path)
        SchematicScalarReference.by_referrer(referrer).by_path(path).delete_all
      end

      # @param [HasSchemaDefinition] referrer
      # @param [String] path
      # @param [ApplicationRecord] referent
      # @return [void]
      def upsert!(referrer, path, referent)
        attributes = {
          referrer_type: referrer.model_name.to_s,
          referrer_id: referrer.id,
          path:,
          referent_type: referent.model_name.to_s,
          referent_id: referent.id
        }

        SchematicScalarReference.upsert(attributes, unique_by: UNIQUE_BY)
      end
    end
  end
end
