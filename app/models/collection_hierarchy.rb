# frozen_string_literal: true

class CollectionHierarchy < ApplicationRecord
  include ClosureTreeHierarchy
  include GenericInaccessible
end
