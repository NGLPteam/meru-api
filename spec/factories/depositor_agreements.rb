# frozen_string_literal: true

FactoryBot.define do
  factory :depositor_agreement do
    association(:submission_target)
    association(:user)

    trait :accepted do
      after(:create) do |depositor_agreement, _|
        depositor_agreement.transition_to! :accepted
      end
    end
  end
end
