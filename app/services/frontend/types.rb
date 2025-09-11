# frozen_string_literal: true

module Frontend
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    Entity = Instance(HierarchicalEntity)

    RevalidationKind = ApplicationRecord.dry_pg_enum("frontend_revalidation_kind")

    ResponseTime = Instance(ActiveSupport::TimeWithZone).constructor do |input|
      case input
      when Integer then ::Time.zone.at(input / 1000.0)
      else
        Params::Time.lax[input] if input.present?
      end&.in_time_zone
    end

    SafeResponseTime = ResponseTime.optional.fallback(nil)
  end
end
