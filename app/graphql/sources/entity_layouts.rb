# frozen_string_literal: true

module Sources
  class EntityLayouts < GraphQL::Dataloader::Source
    # @param [<HierarchicalEntity>] entities
    def fetch(entities)
      threads = entities.map do |entity|
        Async do
          Thread.new do
            ApplicationRecord.connection_pool.with_connection do
              entity.check_layouts.value_or(nil)
            end
          end
        end
      end

      dataloader.yield

      threads.map(&:wait).map(&:value)
    end
  end
end
