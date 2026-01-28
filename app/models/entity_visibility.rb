# frozen_string_literal: true

# This model controls the visibility of {HierarchicalEntity entities} in a way
# that allows them to be connected with adjacent and supporting models, e.g.
# {EntityAdjacent}, {Entity}, and so on.
#
# At any given point, an entity can be in one of three visibility states, represented
# in the database as an enum:
#
# * `visible` An entity is entirely visible
# * `limited` An entity has some kind of range applied that restricts its availability
#   based on the current time. See {#visible_after_at}, {#visible_until_at}.
# * `hidden` An entity is entirely hidden.
#
# A generated attribute, `visibility_range`, is used to handle checking for limited cases.
class EntityVisibility < ApplicationRecord
  include TimestampScopes

  # When scoping, it only makes sense to scope by `hidden`
  # or `visible` for the specified time.
  ScopableVisibility = Support::GlobalTypes::Coercible::Symbol.enum(:hidden, :visible)

  pg_enum! :visibility, as: "entity_visibility", prefix: :visibility

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  scope :visible_at, ->(time) { build_visibility_scope_for(:visible, at: time) }
  scope :hidden_at, ->(time) { build_visibility_scope_for(:hidden, at: time) }

  scope :currently_visible, -> { visible_at Time.current }
  scope :currently_hidden, -> { hidden_at Time.current }

  before_validation :enforce_hidden_visibility!

  validate :enforce_range_with_limited_visibility!

  after_validation :calculate_active!

  def currently_visible?
    visible_as_of? Time.current
  end

  def currently_hidden?
    hidden_as_of? Time.current
  end

  def hidden_as_of?(now = Time.current)
    return false if visibility_visible?

    return true if visibility_hidden?

    !(visible_after?(now) && visible_until?(now))
  end

  def visible_as_of?(now = Time.current)
    return true if visibility_visible?

    return false if visibility_hidden?

    visible_after?(now) && visible_until?(now)
  end

  def visible_after?(now)
    return true if visibility_visible?

    return false if visibility_hidden?

    return true unless visible_after_at?

    visible_after_at < now
  end

  def visible_until?(now)
    return true if visibility_visible?

    return false if visibility_hidden?

    return true unless visible_until_at?

    visible_until_at > now
  end

  private

  # @return [void]
  def calculate_active!
    self.active = derive_active
  end

  # @return [Boolean]
  def derive_active
    case visibility
    in "visible" then true
    in "limited" then visible_as_of?(Time.current)
    else
      false
    end
  end

  # @return [void]
  def enforce_hidden_visibility!
    if visibility_hidden?
      self.hidden_at ||= Time.current
    else
      self.hidden_at = nil
    end
  end

  # @return [void]
  def enforce_range_with_limited_visibility!
    unless visibility_limited?
      self.visible_until_at = nil
      self.visible_after_at = nil

      return
    end

    if visible_after_at? && visible_until_at?
      errors.add :visible_until_at, :before_start if visible_until_at <= visible_after_at
    end

    return if visible_after_at? || visible_until_at?

    errors.add :visibility, :missing_range
  end

  class << self
    # @api private
    # @param [:hidden, :visible] visibility
    # @param [ActiveSupport::TimeWithZone] at
    # @return [ActiveRecord::Relation]
    def build_visibility_scope_for(visibility, at: Time.current)
      visibility = ScopableVisibility[visibility]

      case_expr = arel_case arel_table[:visibility] do |expr|
        expr.when(arel_quote("visible")).then(visibility == :visible)
        expr.when(arel_quote("hidden")).then(visibility == :hidden)
        expr.when(arel_quote("limited")).then(arel_visibility_range_matches(visibility, at:))
        # We allow for the id to be `NULL` when this is `LEFT OUTER JOIN`ed,
        # because we want to allow things like OrderingEntryCandidate to be
        # able to contain communities when searching for visible entities.
        #
        # If we're looking for hidden things and there is no {EntityVisibility},
        # assume it is hidden.
        expr.else(visibility == :hidden || arel_table[:id].eq(nil))
      end

      where(case_expr)
    end

    private

    # @param [:hidden, :visible] visibility
    # @param [ActiveSupport::TimeWithZone] at
    # @return [Arel::Nodes::InfixOperator("@>"), Arel::Nodes::Not(Arel::Nodes::InfixOperator("@>"))]
    def arel_visibility_range_matches(visibility, at:)
      quoted_timestamp = arel_cast(arel_quote(at), "timestamptz")

      arel_infix("@>", arel_table[:visibility_range], quoted_timestamp).then do |contains|
        visibility == :hidden ? arel_not(contains) : contains
      end
    end
  end
end
