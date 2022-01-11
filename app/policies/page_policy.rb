# frozen_string_literal: true

# Most permissions for a {Page} derive from the parent entity's
# `update` permission.
#
# @see Page
class PagePolicy < EntityChildRecordPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
