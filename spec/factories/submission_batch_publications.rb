# frozen_string_literal: true

FactoryBot.define do
  factory :submission_batch_publication do
    transient do
      publications_count { 1 }
    end

    association(:submission_target)
    association(:user)

    after(:create) do |submission_batch_publication, evaluator|
      FactoryBot.create_list(:submission_publication, evaluator.publications_count, submission_batch_publication:)

      submission_batch_publication.reload
    end
  end
end
