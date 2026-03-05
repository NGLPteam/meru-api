# frozen_string_literal: true

module Resolvers
  # @see Announcement
  # @see ::Types::AnnouncementType
  class AnnouncementResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    type ::Types::AnnouncementType.connection_type, null: false

    resolves_model! ::Announcement, must_have_object: true

    description "Announcements for a specific entity"

    option :order, type: ::Types::AnnouncementOrderType, default: "RECENT"

    def apply_order_with_recent(scope)
      scope.recent_published
    end

    def apply_order_with_oldest(scope)
      scope.oldest_published
    end
  end
end
