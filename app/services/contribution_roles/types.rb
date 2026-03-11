# frozen_string_literal: true

module ContributionRoles
  module Types
    extend ::Support::Typespace

    Contributable = ModelInstance("Collection") | ModelInstance("Item")

    Role = ModelInstance("ControlledVocabularyItem")
  end
end
