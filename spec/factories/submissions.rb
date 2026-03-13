# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    association :submission_target
    association :user
    association :schema_version, :collection
    association :parent_entity, factory: :collection

    title { Faker::Lorem.sentence }

    trait :submitted do
      after(:create) do |submission|
        submission.transition_to! :submitted
      end
    end

    trait :under_review do
      after(:create) do |submission|
        submission.transition_to! :submitted
        submission.transition_to! :under_review
      end
    end

    trait :revision_requested do
      after(:create) do |submission|
        submission.transition_to! :submitted
        submission.transition_to! :under_review
        submission.transition_to! :revision_requested
      end
    end

    trait :approved do
      after(:create) do |submission|
        submission.transition_to! :submitted
        submission.transition_to! :under_review
        submission.transition_to! :approved
      end
    end

    trait :rejected do
      after(:create) do |submission|
        submission.transition_to! :submitted
        submission.transition_to! :under_review
        submission.transition_to! :rejected
      end
    end

    trait :published do
      after(:create) do |submission|
        submission.transition_to! :submitted
        submission.transition_to! :under_review
        submission.transition_to! :accepted
        submission.transition_to! :published
      end
    end
  end
end
