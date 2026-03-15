# frozen_string_literal: true

module RecordPreloading
  extend ActiveSupport::Concern

  module ClassMethods
    # @note Intended for use in association scopes.
    #
    # @return [ActiveRecord::Relation]
    def for_preloading
      if record_preloading_active?
        preloaded_for_record_loading
      else
        all
      end
    end

    # @abstract Override in classes
    # @return [ActiveRecord::Relation]
    def preloaded_for_record_loading
      all.preload_associations_lazily
    end

    def record_preloading_active?
      MeruConfig.record_preloading_enabled? && Support::Requests::Current.active?
    end
  end
end
