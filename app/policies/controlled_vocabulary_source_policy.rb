# frozen_string_literal: true

# @see ControlledVocabularySource
class ControlledVocabularySourcePolicy < ApplicationPolicy
  always_readable!

  def create? = false

  def update? = has_admin?

  def destroy? = false
end
