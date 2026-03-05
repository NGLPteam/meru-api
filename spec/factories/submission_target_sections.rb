# frozen_string_literal: true

FactoryBot.define do
  factory :submission_target_section, class: "SubmissionTargets::Section" do
    name { Faker::Lorem.unique.sentence(word_count: 3) }

    content { "Section content goes here." }
  end
end
