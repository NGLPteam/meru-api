# frozen_string_literal: true

FactoryBot.define do
  factory :submission_review do
    association :submission
    association :user

    comment { "This is a comment on the review." }
  end
end
