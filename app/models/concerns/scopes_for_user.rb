# frozen_string_literal: true

module ScopesForUser
  extend ActiveSupport::Concern

  module ClassMethods
    # @param [User, AnonymousUser, <User>, ActiveRecord::Relation<User>, nil] user
    # @return [ActiveRecord::Relation]
    def for_user(user)
      recognized_user?(user) ? where(user:) : for_anonymous_user
    end

    # @see {.for_user}
    # @abstract
    # @return [ActiveRecord::Relation]
    def for_anonymous_user
      none
    end

    # @param [User, AnonymousUser, <User>, ActiveRecord::Relation<User>, String, nil] user
    def recognized_user?(user)
      return false if user.try(:anonymous?)
      return user.model == ::User if user.kind_of?(ActiveRecord::Relation)
      return user.all?(::User) if user.kind_of?(Array)
      return true if Support::GlobalTypes::UUID.valid?(user)

      user.present?
    end
  end
end
