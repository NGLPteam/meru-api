# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::EntityList
    # @see Templates::Instances::FetchEntityList
    # @see Templates::Instances::EntityListFetcher
    # @see Templates::Definitions::HasEntityList
    # @see Types::TemplateEntityListType
    # @see Types::TemplateHasEntityListType
    module HasEntityList
      extend ActiveSupport::Concern
      extend DefinesMonadicOperation

      include ::TemplateInstance
      include Templates::Instances::HasSelectionSource

      included do
        has_one :cached_entity_list, as: :template_instance, class_name: "Templates::CachedEntityList", inverse_of: :template_instance, dependent: :delete

        after_save :clear_entity_list!
      end

      monadic_operation! def cache_entity_list
        call_operation("templates.instances.cache_entity_list", self)
      end

      # @return [Templates::EntityList]
      def entity_list
        @entity_list ||= fetch_entity_list!
      end

      monadic_operation! def fetch_entity_list
        call_operation("templates.instances.fetch_entity_list", self)
      end

      def calculate_hidden
        super || hidden_by_entity_list?
      end

      private

      # @return [void]
      def clear_entity_list!
        @entity_list = nil
      end
    end
  end
end
