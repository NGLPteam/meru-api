# frozen_string_literal: true

module Harvesting
  module Contributors
    class ConnectOrCreate
      include Dry::Monads[:do, :result]
      include MonadicPersistence

      def call(harvest_contributor)
        return Success(harvest_contributor.contributor) if harvest_contributor.contributor.present?

        found = yield maybe_find harvest_contributor

        return connect(harvest_contributor, found) if found.present?

        create_from harvest_contributor
      end

      private

      def connect(harvest_contributor, contributor)
        harvest_contributor.contributor = contributor

        yield monadic_save harvest_contributor

        Success contributor
      end

      def create_from(harvest_contributor)
        contributor = Contributor.new harvest_contributor.slice(
          :identifier, :kind, :email, :prefix, :suffix, :bio, :url
        )

        contributor.properties = harvest_contributor.properties.as_json
        contributor.links = harvest_contributor.links.as_json

        yield monadic_save contributor

        connect harvest_contributor, contributor
      end

      def maybe_find_existing(harvest_contributor)
        if harvest_contributor.person?
          props = harvest_contributor.properties.person

          Contributor.by_given_and_family_name(props.given_name, props.family_name)
        elsif harvest_contributor.organization?
          props = harvest_contributor.properties.organization

          Contributor.by_organization_name(props.legal_name)
        else
          # simplecov:disable
          Contributor.none
          # simplecov:enable
        end.then do |scope|
          maybe_first scope
        end
      end

      def maybe_find_by_identifier(harvest_contributor)
        maybe_first Contributor.by_identifier(harvest_contributor.identifier)
      end

      def maybe_first(scope)
        found = scope.first

        found.present? ? Success(found) : Failure[:not_found]
      end

      def maybe_find(harvest_contributor)
        maybe_find_existing(harvest_contributor).or do
          maybe_find_by_identifier(harvest_contributor).or do
            Success(nil)
          end
        end
      end
    end
  end
end
