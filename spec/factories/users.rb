# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      acl { false }
      manager_on { nil }
      editor_on { nil }
      reviewer_on { nil }
      depositor_on { nil }
      reader_on { nil }
      register_in_keycloak { true }
    end

    keycloak_id { SecureRandom.uuid }

    email { Faker::Internet.email }
    email_verified { false }

    username { email }
    name { "#{given_name} #{family_name}" }

    given_name { Faker::Name.first_name }
    family_name { Faker::Name.last_name }

    roles { [] }
    resource_roles { {} }
    metadata { { "testing" => true } }

    global_access_control_list do
      Roles::GlobalAccessControlList.build_with(acl).as_json
    end

    trait :admin do
      roles { ["global_admin"] }

      after(:create) do |user, evaluator|
        user.enforce_assignments!

        user.assign_global_permissions!
      end
    end

    trait :unknown_in_keycloak do
      register_in_keycloak { false }
    end

    trait :with_avatar do
      avatar do
        Rails.root.join("spec", "data", "lorempixel.jpg").open
      end
    end

    after(:create) do |user, evaluator|
      if evaluator.register_in_keycloak
        Testing::Keycloak::GlobalRegistry.instance.users.add_existing!(user)
      end

      if evaluator.manager_on.present?
        MeruAPI::Container["access.grant"].call(Role.fetch(:manager), on: evaluator.manager_on, to: user)
      end

      if evaluator.editor_on.present?
        MeruAPI::Container["access.grant"].call(Role.fetch(:editor), on: evaluator.editor_on, to: user)
      end

      if evaluator.reviewer_on.present?
        MeruAPI::Container["access.grant"].call(Role.fetch(:reviewer), on: evaluator.reviewer_on, to: user)
      end

      if evaluator.depositor_on.present?
        MeruAPI::Container["access.grant"].call(Role.fetch(:depositor), on: evaluator.depositor_on, to: user)
      end

      if evaluator.reader_on.present?
        MeruAPI::Container["access.grant"].call(Role.fetch(:reader), on: evaluator.reader_on, to: user)
      end
    end
  end
end
