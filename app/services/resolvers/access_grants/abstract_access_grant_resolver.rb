# frozen_string_literal: true

module Resolvers
  module AccessGrants
    module AbstractAccessGrantResolver
      extend ActiveSupport::Concern

      included do
        resolves_model! ::AccessGrant, must_have_object: true
      end

      def resolve_default_scope
        super.with_preloads
      end

      module ForCommunities
        extend ActiveSupport::Concern

        include AbstractAccessGrantResolver

        def resolve_default_scope
          super.for_communities
        end
      end

      module ForCollections
        extend ActiveSupport::Concern

        include AbstractAccessGrantResolver

        def resolve_default_scope
          super.for_collections
        end
      end

      module ForItems
        extend ActiveSupport::Concern

        include AbstractAccessGrantResolver

        def resolve_default_scope
          super.for_items
        end
      end

      module ForGroups
        extend ActiveSupport::Concern

        include AbstractAccessGrantResolver

        def resolve_default_scope
          super.for_groups
        end
      end

      module ForUsers
        extend ActiveSupport::Concern

        include AbstractAccessGrantResolver

        def resolve_default_scope
          super.for_users
        end
      end
    end
  end
end
