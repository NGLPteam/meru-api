# frozen_string_literal: true

module Analytics
  # Types for working with analytics services
  module Types
    extend ::Support::Typespace

    Entity = Entities::Types::Entity

    Entities = Array.of(Entity)

    EventName = String.constrained(format: /\A[a-z]+(?:\.[a-z]+)+\z/)

    Precision = Coercible::String.default("day").enum("hour", "day", "week", "month", "quarter", "year")

    Subject = Instance(::Asset) | Instance(::ApplicationRecord)

    Subjects = Array.of(Subject)

    TimeZone = Instance(ActiveSupport::TimeZone).constructor do |value|
      case value
      when ActiveSupport::TimeZone then value
      when String
        ::Time.find_zone value
      end
    end.fallback do
      MeruAPI::Container["system.time_zone"]
    end.default do
      MeruAPI::Container["system.time_zone"]
    end

    User = Users::Types::Current
  end
end
