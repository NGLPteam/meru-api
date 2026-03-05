# frozen_string_literal: true

FactoryBot.define do
  factory :submission_target do
    entity { FactoryBot.create :collection }

    schema_version { entity.schema_version }
  end
end
