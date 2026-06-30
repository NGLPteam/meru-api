# frozen_string_literal: true

FactoryBot.define do
  factory :submission_target do
    association :entity, factory: :collection, title_prefix: "Submission Target"

    schema_version { entity.schema_version }
  end
end
