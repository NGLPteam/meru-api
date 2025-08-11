# frozen_string_literal: true

module Harvesting
  module Assets
    class ScalarReference
      include Support::EnhancedStoreModel

      attribute :full_path, :string
      attribute :asset, Harvesting::Assets::ExtractedSource.to_type

      validates :full_path, presence: true

      def blank?
        super || asset.blank?
      end
    end
  end
end
