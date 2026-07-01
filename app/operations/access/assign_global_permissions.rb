# frozen_string_literal: true

module Access
  # Using {PrimaryRoleAssignment}, derive the {Roles::GlobalAccessControlList global permissions}
  # that a given {AccessGrantSubject} should have applied.
  class AssignGlobalPermissions
    include Dry::Monads[:result]
    include MonadicPersistence

    # @param [AccessGrantSubject] subject
    # @return [Dry::Monads::Success(AccessGrantSubject)]
    # @return [Dry::Monads::Failure]
    def call(subject)
      gacl = gacl_for primary_role_for(subject)

      case subject
      when ::User
        handle_user subject, gacl
      else
        # simplecov:disable
        Success(subject)
        # simplecov:enable
      end
    end

    private

    # @param [User] user
    # @param [Roles::GlobalAccessControlList] gacl
    # @return [Dry::Monads::Success(User)]
    # @return [Dry::Monads::Failure]
    def handle_user(user, gacl)
      user.global_access_control_list = gacl

      monadic_save user
    end

    # @param [Role] role
    # @return [Roles::GlobalAccessControlList]
    def gacl_for(role)
      if role.present?
        role.global_access_control_list
      else
        Roles::GlobalAccessControlList.define do |gacl|
          gacl.allow! "roles.read"
        end
      end
    end

    # @param [AccessGrantSubject] subject
    # @return [Role, nil]
    def primary_role_for(subject)
      subject.reload_primary_role || default_role_for(subject)
    end

    # @param [AccessGrantSubject] subject
    # @return [Role, nil]
    def default_role_for(subject)
      case subject
      when ::User
        # In the absence of any existing entities, ensure admins still have admin GACL
        return Role.fetch(:admin) if subject.has_global_admin_access?
      end
    end
  end
end
