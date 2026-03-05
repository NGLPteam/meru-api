# frozen_string_literal: true

# @see ControlledVocabularyItem
class ControlledVocabularyItemPolicy < ApplicationPolicy
  always_readable!

  def destroy? = false
end
