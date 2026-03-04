# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    transient do
      actions { [] }
    end

    name { Faker::Lorem.unique.word }

    custom_priority { Faker::Number.unique.rand(-19_999...20_000) }

    %i[admin manager editor reviewer depositor reader].each do |key|
      system_role = SystemRole.find key.to_s

      trait key do
        identifier { system_role.identifier }
        name { system_role.name }
        access_control_list { system_role.acl.as_json }
        global_access_control_list { system_role.gacl.as_json }
        custom_priority { nil }
      end
    end

    trait(:all_contextual) do
      access_control_list do
        Roles::AccessControlList.define do |acl|
          acl.allow! ?*
          acl.deny! "*.manage_access"
        end
      end
    end

    to_create do |instance|
      existing = instance.identifier.present? ? Role.fetch(instance.identifier) : nil

      if existing
        instance.id = existing.id
      else
        attrs, unique_by = instance.to_upsert

        attrs[:created_at] = Time.current
        attrs[:updated_at] = Time.current

        results = Role.upsert(attrs, unique_by:, returning: %w[id])

        id = results.first["id"]

        instance.id = id
      end

      instance.reload.tap(&:calculate_role_permissions!)
    end
  end
end
