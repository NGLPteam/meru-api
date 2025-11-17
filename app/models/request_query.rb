# frozen_string_literal: true

class RequestQuery < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  pg_enum! :kind, as: :request_query_kind, default: :query, allow_blank: false

  has_many :request_steps, inverse_of: :request_query, dependent: :delete_all
  has_many :request_timings, inverse_of: :request_query, dependent: :delete_all

  before_validation :derive_query_info!
  before_validation :derive_digest!, on: :create

  validates :query, :digest, presence: true
  validates :query, uniqueness: true

  private

  # @return [void]
  def derive_digest!
    self.digest = Digest::SHA256.hexdigest(query.to_s)
  end

  def derive_query_info!
    parsed = ::GraphQL.parse(query.to_s)

    definition = parsed.definitions.first

    set_kind_from_definition!(definition)

    self.operation_name = operation_name.presence || definition.name
  rescue GraphQL::ParseError
    # :nocov:
    errors.add(:query, "is not valid GraphQL")
    # :nocov:
  end

  def set_kind_from_definition!(definition)
    # :nocov:
    case definition.try(:operation_type)
    in "query"
      self.kind = :query
    in "mutation"
      self.kind = :mutation
    in "subscription"
      self.kind = :subscription
    else
      self.kind = :other
    end
    # :nocov:
  end
end
