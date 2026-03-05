# frozen_string_literal: true

module Support
  module GraphQLAPI
    module Enhancements
      # @note `extend` this on `Types::BaseInterface`.
      module Interface
        class << self
          def extended(base)
            base.include GraphQL::Schema::Interface
            base.include Support::GraphQLAPI::AssociationHelpers
            base.include Support::GraphQLAPI::DirectConnectionAndEdgeSupport
            base.include Support::GraphQLAPI::ImageAttachmentSupport
            base.extend Support::GraphQLAPI::Enhancements::Interface::Composable
            base.extend Support::GraphQLAPI::ExposeAuthorization
          end
        end

        module Composable
          def included(base)
            super if defined?(super)

            base.include ActionPolicy::Behaviour
            base.include ActionPolicy::GraphQL::Fields

            base.extend Support::GraphQLAPI::AssociationHelpers::ClassMethods
            base.extend Support::GraphQLAPI::DirectConnectionAndEdgeSupport::ClassMethods
            base.extend Support::GraphQLAPI::ImageAttachmentSupport::ClassMethods
            base.extend Support::GraphQLAPI::ExposeAuthorization
          end
        end
      end
    end
  end
end
