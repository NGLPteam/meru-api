# frozen_string_literal: true

module Links
  # @see EntityLink#check!
  class Maintain
    include Dry::Monads[:result]

    # @param [HierarchicalEntity] entity
    # @return [Dry::Monads::Success(void)]
    def call(entity)
      EntityLink.by_source_or_target(entity).find_each do |link|
        link.check!
      end

      Success()
    end
  end
end
