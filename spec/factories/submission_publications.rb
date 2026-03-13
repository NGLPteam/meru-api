# frozen_string_literal: true

FactoryBot.define do
  factory :submission_publication do
    submission_batch_publication { nil }

    submission do
      next FactoryBot.create(:submission, :approved) unless submission_batch_publication.present?

      submission_target = submission_batch_publication.submission_target

      FactoryBot.create(:submission, :approved, submission_target:)
    end

    user do
      submission_batch_publication&.user || create(:user)
    end
  end
end
