# frozen_string_literal: true

FactoryBot.define do
  factory :community do
    transient do
      schema { nil }

      sequence(:seq) { _1 }

      title_prefix { "Community" }
    end

    title { "#{title_prefix} #{seq}" }

    schema_version { schema.present? ? SchemaVersion[schema] : SchemaVersion.default_community }

    pending_properties { {} }

    trait :simple do
      title_prefix { "Simple Community" }

      association :schema_version, :simple_community, :v1
    end

    trait :with_logo do
      logo do
        Rails.root.join("spec", "data", "lorempixel.jpg").open
      end
    end

    trait :with_thumbnail do
      thumbnail do
        Rails.root.join("spec", "data", "lorempixel.jpg").open
      end
    end
  end
end
