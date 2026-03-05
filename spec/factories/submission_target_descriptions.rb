# frozen_string_literal: true

FactoryBot.define do
  factory :submission_target_description, class: "SubmissionTargets::Description" do
    transient do
      sections_count { 3 }
    end

    internal { Faker::Lorem.paragraph }

    instructions { Faker::Lorem.paragraph }

    sections do
      sections_count.times.map do
        FactoryBot.attributes_for(:submission_target_section)
      end
    end
  end
end
