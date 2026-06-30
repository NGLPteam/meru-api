# frozen_string_literal: true

FactoryBot.define do
  factory :submission_review do
    association :submission

    association :user, name_prefix: "Submission", name_suffix: "Reviewer"

    comment { "This is a comment on the review." }

    trait :revision_requested do
      after :create do |review|
        review.transition_to! :revision_requested
      end
    end

    trait :approved do
      after :create do |review|
        review.transition_to! :approved
      end
    end

    trait :rejected do
      after :create do |review|
        review.transition_to! :rejected
      end
    end
  end
end
