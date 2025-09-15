# frozen_string_literal: true

FactoryBot.define do
  factory :permalink do
    association :permalinkable, factory: :community

    canonical { false }

    sequence(:uri) { |n| "permalink-#{n}" }

    trait :canon do
      canonical { true }
    end
  end
end
