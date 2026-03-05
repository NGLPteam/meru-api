# frozen_string_literal: true

module Harvesting
  module Options
    # @api private
    class List
      include StoreModel::Model
      include Support::EnhancedStoreModel
    end
  end
end
