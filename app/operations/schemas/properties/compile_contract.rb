# frozen_string_literal: true

module Schemas
  module Properties
    class CompileContract
      include Dry::Monads[:do, :result]
      include MeruAPI::Deps[compile_schema: "schemas.properties.compile_schema"]

      # @param [SchemaVersion, Schema::Versions::Configuration, <Schemas::Versions::ScalarProperties::Base, Schemas::Versions::PropertyGroupDefinition>] source
      # @return [Dry::Monads::Result::Success(Class)]
      # @return [Dry::Monads::Result::Failure(Symbol, String)]
      def call(source)
        case source
        when Schemas::Types::PropertyList
          build_contract source
        when Schemas::Versions::Configuration, Schemas::Properties::GroupDefinition
          build_contract source.properties
        when Schemas::Properties::Types.Interface(:properties)
          # simplecov:disable
          call(source.properties)
          # simplecov:enable
        when ::SchemaVersion
          call source.configuration
        else
          Failure(nil)
        end.or do
          Failure[:invalid_source, "Cannot derive properties from #{source.inspect}"]
        end
      end

      private

      # @param [<Schemas::Versions::ScalarProperties::Base, Schemas::Versions::PropertyGroupDefinition>] properties
      # @return [Dry::Monads::Result::Success(Class)]
      def build_contract(properties)
        groups, scalar = properties.partition(&:group?)

        group_contracts = groups.map do |group|
          [group, group.to_dry_validation]
        end

        contract_klass = Class.new(::Schemas::BaseContract)

        contract_klass.params do
          group_contracts.each do |(group, contract)|
            if group.required?
              required(group.key).filled(contract.schema)
            else
              optional(group.key).maybe(contract.schema)
            end
          end

          scalar.each do |property|
            property.add_to_schema! self
          end
        end

        group_contracts.each do |(group, contract)|
          contract_klass.rule(group.key).validate(contract:)
        end

        scalar.each do |property|
          property.add_to_rules! contract_klass
        end

        Success contract_klass.new
      end
    end
  end
end
