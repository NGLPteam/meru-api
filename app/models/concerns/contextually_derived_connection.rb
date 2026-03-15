# frozen_string_literal: true

# A model that includes this concern belongs to {ContextualPermission} based on
# a combination of three columns:
#
# * `user_id`
# * `hierarchical_type`
# * `hierarchical_id`
#
# It is used to connect the ContextualPermission to other models in the system.
module ContextuallyDerivedConnection
  extend ActiveSupport::Concern

  include SkipsPreloading
  include View

  CONTEXT_KEY = %i[user_id hierarchical_type hierarchical_id].freeze

  CONTEXT_PKEYS = Support::GlobalTypes::Array.of(Support::GlobalTypes::Coercible::Symbol).constrained(min_size: 1)

  class_methods do
    # @!macro [attach] belongs_to_contextual_permission
    #   @!parse ruby
    #     # @note This association is read-only (likely against a database view).
    #     belongs_to :contextual_permission, -> { readonly }
    def belongs_to_contextual_permission(inverse_of:, **options)
      options[:primary_key] ||= CONTEXT_KEY
      options[:foreign_key] ||= CONTEXT_KEY
      options[:inverse_of] = inverse_of

      belongs_to_readonly :contextual_permission, **options
    end

    # Define the contextual primary key for this view based on {CONTEXT_KEY}.
    #
    # @param [<Symbol>] other_keys
    # @return [void]
    def contextual_primary_key!(*other_keys)
      other_keys.flatten!

      keys = CONTEXT_PKEYS[other_keys]

      self.primary_key = CONTEXT_KEY | keys
    end
  end
end
