# frozen_string_literal: true

FactoryBot.define do
  factory :harvest_contributor do
    association :harvest_source

    identifier { SecureRandom.uuid }

    email { Faker::Internet.email }
    url { Faker::Internet.url }
    bio { Faker::Lorem.paragraphs(number: 4).join("\n") }

    links do
      [{ url: Faker::Internet.url, title: Faker::Lorem.sentence }]
    end

    trait :organization do
      transient do
        legal_name { Faker::Company.name }
        location { Faker::Address.full_address }
      end

      kind { :organization }

      properties do
        {
          organization: {
            legal_name:,
            location:
          }
        }
      end
    end

    trait :person do
      transient do
        given_name { Faker::Name.first_name }
        family_name { Faker::Name.last_name }
        title { Faker::Name.prefix }
        affiliation { Faker::Company.name }
      end

      kind { :person }

      properties do
        {
          person: {
            given_name:,
            family_name:,
            title:,
            affiliation:
          }
        }
      end
    end
  end
end
