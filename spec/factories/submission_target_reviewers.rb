# frozen_string_literal: true

FactoryBot.define do
  factory :submission_target_reviewer do
    association :submission_target
    association :user, name_prefix: "Submission", name_suffix: "Reviewer"
  end
end
