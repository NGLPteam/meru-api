# frozen_string_literal: true

# A materialized view composed of author-level {Contribution} records
# that is fed into {EntitySearchDocument} and refreshed by a job.
#
# Never accessed directly in GQL or elsewhere.
#
# @see Entities::RefreshAuthorContributionsJob
class EntityAuthorContribution < ApplicationRecord
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include MaterializedView
  include TimestampScopes
end
