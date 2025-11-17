# frozen_string_literal: true

module Support
  module GraphQLAPI
    # Helper methods for ensuring associations are loaded.
    module AssociationHelpers
      extend ActiveSupport::Concern

      # @param [Symbol] association
      # @param [Class(ApplicationRecord), nil] klass
      # @param [ApplicationRecord, Object] record
      # @return [Promise, Object]
      def association_loader_for(association, klass: object&.class, record: object)
        if !record.kind_of?(ActiveRecord::Base)
          # Handle AnonymousUser, other proxies
          record.try(association)
        elsif record.association(association).loaded?
          record.public_send(association)
        elsif MeruConfig.experimental_dataloader?
          # :nocov:
          dataloader.with(GraphQL::Dataloader::ActiveRecordAssociationSource, association).load(record)
          # :nocov:
        else
          Support::Loaders::AssociationLoader.for(klass, association).load(record)
        end
      end

      def load_record_with(klass, id, **options)
        if MeruConfig.experimental_dataloader?
          # :nocov:
          dataloader.with(GraphQL::Dataloader::ActiveRecordSource, klass, **options).load(id)
          # :nocov:
        else
          Support::Loaders::RecordLoader.for(klass, **options).load(id)
        end
      end

      # If we are using graphql-batch / promises, await the promises.
      # Otherwise, just return the values as-is.
      def maybe_await(promises)
        # :nocov:
        return promises if MeruConfig.experimental_dataloader?
        # :nocov:

        Promise.all(promises)
      end

      module ClassMethods
        # @param [Symbol] association_name
        # @param [Symbol] as
        # @return [void]
        def load_association!(association_name, as: association_name)
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{as}                                                     # def foo
            association_loader_for(#{association_name.to_sym.inspect})  #   association_loader_for(:foo)
          end                                                           # end
          RUBY
        end

        # @param [Symbol] from
        # @return [void]
        def load_current_state!(from: :transitions)
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def current_state
            #{from}.then do
              object.current_state
            end
          end
          RUBY
        end
      end
    end
  end
end
