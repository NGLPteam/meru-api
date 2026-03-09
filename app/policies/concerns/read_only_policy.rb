# frozen_string_literal: true

module ReadOnlyPolicy
  extend ActiveSupport::Concern

  included do
    always_readable!
  end

  def create? = false

  def update? = false

  def destroy? = false
end
