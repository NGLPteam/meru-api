# frozen_string_literal: true

FactoryBot.define do
  factory :submission_publication do
    transient do
      sequence(:title) { "Submission Publication #{_1}" }
    end

    submission_batch_publication { nil }

    submission do
      attrs = { title: }

      attrs[:submission_target] = submission_batch_publication.submission_target if submission_batch_publication.present?

      FactoryBot.create(:submission, :approved, **attrs)
    end

    user do
      submission_batch_publication&.user || create(:user, given_name: "Submission Publication", family_name: "Publisher")
    end
  end
end
