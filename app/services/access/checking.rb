# frozen_string_literal: true

module Access
  module Checking
    extend ActiveSupport::Concern

    # @param [Accessible] accessible
    # @raise [Access::AccessibleError] if the accessible is not a {HierarchicalEntity}.
    def require_entity!(accessible)
      case accessible
      in Types::Entity => entity
        return entity
      else
        # simplecov:disable
        raise AccessibleError, "Expected a HierarchicalEntity, got #{accessible.class}"
        # simplecov:enable
      end
    end

    def require_submittable!(accessible)
      entity = require_entity!(accessible)

      case entity
      in ::Submittable
        return entity
      else
        # simplecov:disable
        raise AccessibleError, "Expected a Submittable entity, got #{entity.class}"
        # simplecov:enable
      end
    end

    # @param [AccessGrantSubject] subject
    # @raise [Access::SubjectError] if the subject is not a {User}.
    # @return [User]
    def require_user!(subject)
      case subject
      in Types::User => user
        return user
      else
        raise UserOnlyError, "Expected a User, got #{subject.class}"
      end
    end
  end
end
