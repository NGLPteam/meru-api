# frozen_string_literal: true

# @!parse [ruby]
#   # A null object using [Naught](https://github.com/avdi/naught) to mimic {User}
#   # in cases when a request is not authenticated. Policies and other aspects of
#   # the GraphQL API rely on a non-nil value representing the user accessing a given
#   # object.
#   #
#   # @subsystem Authentication
#   # @subsystem Authorization
#   class AnonymousUser < Naught
#     include AnonymousInterface
#     include GlobalID::Identification
#     extend AnonymousInterface::ClassMethods
#   end
AnonymousUser = Naught.build do |config|
  include ::Support::Users::AnonymousInterface
  include AnonymousInterface

  config.mimic User

  config.predicates_return false
end

AnonymousUser.extend ::Support::Users::AnonymousInterface::ClassMethods
