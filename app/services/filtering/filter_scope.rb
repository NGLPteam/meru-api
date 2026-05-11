# frozen_string_literal: true

module Filtering
  # The base class for building filter scopes. It has a fluent DSL for defining filtering
  # arguments, and methods for applying those filters to an ActiveRecord scope.
  #
  # Filter scope implementations live in {Filtering::Scopes} and follow a convention of
  # being named in a plural of the model they filter, e.g. {Filtering::Scopes::Users}
  # serves as the filter scope for the `User` model. When inheriting from this class,
  # the model class that is wrapped is provided to {.[]} in order to automatically make
  # the necessary connections and definitions.
  #
  # @abstract
  class FilterScope < ::Support::Filtering::DefaultScope
    option :current_user, ::Users::Types::Current, default: ::Users::Types::DEFAULT_FROM_REQUEST

    def has_admin_access? = current_user.try(:has_admin_access?)
  end
end
