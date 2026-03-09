# frozen_string_literal: true

# A generic policy for records that can be read by anyone but not modified.
# This is for certain records that don't justify having their own policy class.
#
# @see GenericAccessible
class GenericAccessiblePolicy < ApplicationPolicy
  include ReadOnlyPolicy
end
