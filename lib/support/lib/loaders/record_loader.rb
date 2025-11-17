# frozen_string_literal: true

module Support
  module Loaders
    # A loader for a specific record.
    class RecordLoader < GraphQL::Batch::Loader
      def initialize(model, find_by: model.primary_key, order: nil, where: nil)
        super()
        @model = model
        @find_by = find_by.to_s
        @find_by_type = model.type_for_attribute(@find_by)
        @order = order if order.present?
        @is_primary_key = find_by == model.primary_key
        @where = where
      end

      def load(key)
        super(@find_by_type.cast(key))
      end

      def perform(keys)
        query(keys).each do |record|
          key = record.public_send(@find_by)

          next if fulfilled? key

          fulfill(key, record)
        end

        keys.each { |key| fulfill(key, nil) unless fulfilled?(key) }
      end

      private

      def query(keys)
        scope = @model.all
        scope = scope.where(@where) if @where

        unless @is_primary_key
          scope = scope.distinct_on @find_by
          scope = scope.order @find_by
          scope = scope.order @order
        end

        scope.where(@find_by => keys)
      end
    end
  end
end
