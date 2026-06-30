# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    transient do
      schema { nil }

      sequence(:seq) { _1 }

      title_prefix { "Collection" }
    end

    association :community

    schema_version { schema.present? ? SchemaVersion[schema] : SchemaVersion.default_collection }

    title { "#{title_prefix} #{seq}" }
    identifier { title.parameterize }

    raw_doi { nil }
    summary { Faker::Lorem.paragraph }

    visibility { :visible }

    pending_properties { {} }

    trait :hidden do
      title_prefix { "Hidden Collection" }

      visibility { :hidden }
    end

    trait :limited do
      title_prefix { "Limited Visibility Collection" }

      visibility { :limited }

      visible_after_at { 1.day.ago }
      visible_until_at { 1.day.from_now }
    end

    trait :with_hero_image do
      hero_image do
        Rails.root.join("spec", "data", "lorempixel.jpg").open
      end
    end

    trait :with_thumbnail do
      thumbnail do
        Rails.root.join("spec", "data", "lorempixel.jpg").open
      end
    end

    trait :journal do
      title_prefix { "Journal" }

      schema_version { SchemaVersion["nglp:journal"] }
    end

    trait :journal_volume do
      title_prefix { "Journal Volume" }

      schema_version { SchemaVersion["nglp:journal_volume"] }
    end

    trait :journal_issue do
      title_prefix { "Journal Issue" }

      schema_version { SchemaVersion["nglp:journal_issue"] }
    end

    trait :series do
      title_prefix { "Series" }

      schema_version { SchemaVersion["nglp:series"] }
    end

    trait :unit do
      title_prefix { "Unit" }

      schema_version { SchemaVersion["nglp:unit"] }
    end
  end
end
