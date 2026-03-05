# frozen_string_literal: true

module Resolvers
  module FiltersByAccessGrantSubject
    extend ActiveSupport::Concern

    included do
      option :subject, type: ::Types::AccessGrantSubjectFilterType, default: "ALL"
    end

    def apply_subject_with_all(scope)
      scope.all
    end

    def apply_subject_with_group(scope)
      scope.for_groups
    end

    def apply_subject_with_user(scope)
      scope.for_users
    end
  end
end
