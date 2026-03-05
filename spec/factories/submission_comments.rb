# frozen_string_literal: true

FactoryBot.define do
  factory :submission_comment do
    association :submission
    association :user

    content { "This is a comment on the submission." }
  end
end
