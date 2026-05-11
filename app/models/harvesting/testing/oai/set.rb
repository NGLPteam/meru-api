# frozen_string_literal: true

module Harvesting
  module Testing
    module OAI
      class Set < ::ApplicationFrozenRecord
        include Dry::Core::Equalizer.new(:spec)

        schema!(types: ::Harvesting::Testing::TypeRegistry) do
          required(:spec).value(:oai_set_spec)
          required(:name).filled(:string)
          required(:description).value(:string)
          required(:matcher).value(Harvesting::Testing::Types.Instance(::Harvesting::Testing::OAI::SetSpecMatcher))
        end

        self.primary_key = :spec

        add_index :spec, unique: true

        default_attributes!(description: "")

        calculates! :matcher do |record|
          ::Harvesting::Testing::OAI::SetSpecMatcher.new([record["spec"]])
        end
      end
    end
  end
end
