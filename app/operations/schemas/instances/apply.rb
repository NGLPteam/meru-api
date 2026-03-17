# frozen_string_literal: true

module Schemas
  module Instances
    # Validates and saves schema values from any source to an entity.
    #
    # To patch a partial set of properties, use {Schemas::Instances::PatchProperties}.
    #
    # @see Schemas::Instances::PropertiesApplicator
    class Apply < Support::SimpleServiceOperation
      service_klass Schemas::Instances::PropertiesApplicator
    end
  end
end
