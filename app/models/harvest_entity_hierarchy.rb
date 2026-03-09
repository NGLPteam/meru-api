# frozen_string_literal: true

class HarvestEntityHierarchy < ApplicationRecord
  include ClosureTreeHierarchy
  include GenericInaccessible
end
