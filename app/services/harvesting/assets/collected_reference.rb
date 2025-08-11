# frozen_string_literal: true

module Harvesting
  module Assets
    class CollectedReference
      include Support::EnhancedStoreModel

      attribute :full_path, :string
      attribute :assets, Harvesting::Assets::ExtractedSource.to_array_type, default: proc { [] }

      validates :full_path, presence: true

      def blank?
        super || assets.blank?
      end
    end
  end
end
