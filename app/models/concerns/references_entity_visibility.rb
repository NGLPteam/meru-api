# frozen_string_literal: true

# A concern for reading from a `has_one :entity_visibility` association.
#
# It is designed so that {Entity}, {OrderingEntryCandidate}, and other similar reference
# models can have a unified API to our "real" data models, i.e. {Item} and {Collection}.
#
# @see HasEntityVisibility
module ReferencesEntityVisibility
  extend ActiveSupport::Concern

  included do
    delegate :visibility,
      :visible_until_at,
      :visible_after_at,
      :hidden_at,
      :visibility_hidden?,
      :visibility_visible?,
      :visibility_limited?,
      :visible_as_of?,
      :hidden_as_of?,
      :currently_hidden?,
      :currently_visible?,
      to: :actual_entity_visibility

    scope :visible_at, ->(time) { left_outer_joins(:entity_visibility).merge(EntityVisibility.visible_at(time)) }
    scope :hidden_at, ->(time) { joins(:entity_visibility).merge(EntityVisibility.hidden_at(time)) }

    scope :currently_visible, -> { visible_at Time.current }
    scope :currently_hidden, -> { hidden_at Time.current }
  end

  # @!attribute [r] actual_entity_visibility
  # This can be used to auto-instantiate the entity visibility record
  # when it is not yet created.
  # @return [EntityVisibility]
  def actual_entity_visibility
    entity_visibility || build_entity_visibility
  end
end
