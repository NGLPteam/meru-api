# frozen_string_literal: true

module Harvesting
  module Assets
    class Mapping
      include Support::EnhancedStoreModel

      attribute :entity, Harvesting::Assets::EntityMapping.to_type, default: proc { {} }
      attribute :unassociated, Harvesting::Assets::ExtractedSource.to_array_type, default: proc { [] }
      attribute :scalar, Harvesting::Assets::ScalarReference.to_array_type, default: proc { [] }
      attribute :collected, Harvesting::Assets::CollectedReference.to_array_type, default: proc { [] }

      delegate(*Harvesting::Assets::EntityMapping::IMAGE_REMOTE_URLS, to: :entity)

      def no_submappings?
        submappings.blank?
      end

      def submappings
        [
          entity,
          unassociated,
          scalar,
          collected,
        ].compact_blank
      end

      def blank?
        super || submappings.blank?
      end
    end
  end
end
