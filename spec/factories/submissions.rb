# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    association :submission_target
    association :user
    association :schema_version, :collection
    association :parent_entity, factory: :collection

    title { Faker::Lorem.sentence }
  end
end
