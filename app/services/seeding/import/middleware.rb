# frozen_string_literal: true

module Seeding
  module Import
    class Middleware
      include Dry::Core::Memoizable
      include Dry::Effects::Handler.Cache(:import)
      include Dry::Effects::Handler.Resolve
      include Dry::Monads[:result]
      include Dry::Initializer[undefined: false].define -> do
        param :import, Seeding::Import::Structs::Import::Type
      end

      extend ActiveModel::Callbacks

      define_model_callbacks :import

      around_import :with_cache
      around_import :with_provisions
      around_import :with_delayed_orderings

      # @return [Dry::Monads::Result]
      def call
        run_callbacks :import do
          yield import
        end

        Success import
      end

      private

      memoize def provisions
        {}.tap do |h|
          h[:import] = import
          h[:import_version] = import.version
        end
      end

      def with_delayed_orderings
        Schemas::Orderings.with_asynchronous_refresh do
          yield
        end
      end

      # @return [void]
      def with_provisions
        provide provisions do
          yield
        end
      end
    end
  end
end
