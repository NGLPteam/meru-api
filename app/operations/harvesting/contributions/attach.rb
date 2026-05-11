# frozen_string_literal: true

module Harvesting
  module Contributions
    # Create a {Contribution} from a {HarvestContribution}.
    #
    # @see ::Contributions::Attach
    # @see ::Contributions::Attacher
    # @see ::Harvesting::Contributors::ConnectOrCreate
    class Attach
      include Dry::Monads[:do, :result]
      include MonadicPersistence
      include MeruAPI::Deps[
        connect_or_create: "harvesting.contributors.connect_or_create",
      ]

      # @param [HarvestContribution] harvest_contribution
      # @param [Contributable] contributable
      # @return [Dry::Monads::Success(Contribution)]
      def call(harvest_contribution, contributable)
        contributor = yield connect_or_create.call(harvest_contribution.harvest_contributor)

        options = harvest_contribution.to_attach_options

        contributable.attach_contribution(contributor, **options)
      end
    end
  end
end
