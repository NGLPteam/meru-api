# frozen_string_literal: true

module Mutations
  module Operations
    # The actual implementation for {Mutations::ReparentEntity}.
    #
    # @see Mutations::Contracts::ReparentEntity
    # @see Schemas::Instances::ReparentEntity
    class ReparentEntity
      include MutationOperations::Base
      include Mutations::Shared::ForceRendersLayouts
      include Mutations::Shared::RefreshesOrderingsAsynchronously

      derives_edge!

      use_contract! :reparent_entity

      authorizes! :child, with: :reparent?

      def call(parent:, child:)
        authorize parent, derived_edge.roles.create_children

        with_called_operation!("schemas.instances.reparent_entity", parent, child) do |m|
          m.success do |updated_child|
            force_render_layouts_for! parent, updated_child

            attach! :parent, parent
            attach! :child, updated_child
          end

          m.failure do
            # :nocov:
            add_global_error! "Something went wrong"
            # :nocov:
          end
        end
      end
    end
  end
end
