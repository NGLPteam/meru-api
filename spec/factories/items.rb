# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    transient do
      schema { nil }

      sequence(:seq) { _1 }

      title_prefix { "Item" }
    end

    association :collection

    schema_version { schema.present? ? SchemaVersion[schema] : SchemaVersion.default_item }

    title { "#{title_prefix} #{seq}" }
    identifier { title.parameterize }

    raw_doi { nil }
    summary { Faker::Lorem.paragraph }

    visibility { :visible }

    pending_properties { {} }

    trait :hidden do
      title_prefix { "Hidden Item" }

      visibility { :hidden }
    end

    trait :limited do
      title_prefix { "Limited Visibility Item" }

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

    trait :journal_article do
      transient do
        issue_position { nil }

        schema_properties do
          {
            issue_position:,
          }
        end
      end

      title_prefix { "Journal Article" }

      schema { "nglp:journal_article" }

      after(:create) do |item, evaluator|
        item.patch_properties!(evaluator.schema_properties)
      end
    end
  end
end
