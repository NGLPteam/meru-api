# frozen_string_literal: true

module Harvesting
  module Testing
    module OAI
      class SetSpecMatcher
        include Comparable
        include Dry::Core::Constants
        include Dry::Initializer[undefined: true].define -> do
          param :specs, Harvesting::Testing::Types::OAISetSpecs
        end

        def ==(other_value)
          covers?(other_value)
        end

        def <=>(other_value)
          covers?(other_value) ? 0 : -1
        end

        # @param [String, <String>, Harvesting::Testing::OAI::SetSpecMatcher] other_value
        def covers?(other_value)
          other = self.class.matcher_for(other_value)

          specs.any? do |spec|
            other.covered_by?(spec)
          end
        end

        protected

        def covered_by?(target_spec)
          return false if specs.blank?

          specs.any? do |spec|
            spec == target_spec || spec.starts_with?("#{target_spec}:")
          end
        end

        class << self
          # @param [String, <String>, Harvesting::Testing::OAI::SetSpecMatcher] other_value
          # @return [Harvesting::Testing::OAI::SetSpecMatcher]
          def matcher_for(other_value)
            case other_value
            when self then other_value
            when Harvesting::Testing::Types::OAISetSpecs then new(other_value)
            when Harvesting::Testing::Types::OAISetSpec then new([other_value])
            when "", nil then new(EMPTY_ARRAY)
            else
              # simplecov:disable
              raise TypeError, "#{other_value.inspect} is not comparable"
              # simplecov:enable
            end
          end
        end
      end
    end
  end
end
