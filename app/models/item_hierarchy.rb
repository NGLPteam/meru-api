# frozen_string_literal: true

class ItemHierarchy < ApplicationRecord
  include ClosureTreeHierarchy
  include GenericInaccessible
end
