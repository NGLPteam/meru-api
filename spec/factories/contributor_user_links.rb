# frozen_string_literal: true

FactoryBot.define do
  factory :contributor_user_link do
    association :contributor, :person
    association :user

    linkage { "auxiliary" }

    trait :primary do
      linkage { "primary" }
    end

    trait :auxiliary do
      linkage { "auxiliary" }
    end
  end
end
