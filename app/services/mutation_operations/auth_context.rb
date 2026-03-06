# frozen_string_literal: true

module MutationOperations
  class AuthContext
    include ActionPolicy::Behaviour
    include ActionPolicy::Behaviours::ThreadMemoized
    include ActionPolicy::Behaviours::Memoized

    include Dry::Initializer[undefined: false].define -> do
      option :current_user, Users::Types::Current, default: proc { AnonymousUser.new }
    end

    authorize :user, through: :current_user
  end
end
