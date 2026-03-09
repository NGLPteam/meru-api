# frozen_string_literal: true

class ControlledVocabularyItemHierarchy < ApplicationRecord
  include ClosureTreeHierarchy
  include GenericInaccessible
end
