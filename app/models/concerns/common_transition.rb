# frozen_string_literal: true

# A concern for common transition scopes and methods.
module CommonTransition
  extend ActiveSupport::Concern

  include HasEphemeralSystemSlug
  include ::Support::Requests::ReadsCurrentUser
  include TimestampScopes

  included do
    scope :in_graphql_order, -> { order(sort_key: :desc) }

    before_create :maybe_capture_current_user!
  end

  private

  # @return [void]
  def maybe_capture_current_user!
    self.user = current_user if current_user.present? && current_user.authenticated?
  end

  module ClassMethods
    def has_metadata_class?
      attribute_types["metadata"].kind_of?(StoreModel::Types::One)
    end

    # @param [Hash] metadata
    # @return [Hash]
    def normalize_metadata(**raw_metadata)
      return raw_metadata unless has_metadata_class?

      attribute_types["metadata"].cast(raw_metadata).tap(&:valid?).as_json.deep_symbolize_keys
    end

    # Sets up the `from_state` and `to_state` enum columns for a transition model.
    # @param [Symbol, String] enum_type
    # @return [void]
    def stateful_enum!(enum_type)
      pg_enum! :from_state, as: enum_type, prefix: :from, allow_blank: true
      pg_enum! :to_state, as: enum_type, prefix: :to
    end
  end
end
