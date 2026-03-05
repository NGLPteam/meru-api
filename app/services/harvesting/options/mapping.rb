# frozen_string_literal: true

module Harvesting
  module Options
    # @api private
    class Mapping
      include StoreModel::Model
      include Support::EnhancedStoreModel

      attribute :auto_create_volumes_and_issues, :boolean, default: false
      attribute :link_identifiers_globally, :boolean, default: false
      attribute :use_metadata_mappings, :boolean, default: false
    end
  end
end
