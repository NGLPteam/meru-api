# frozen_string_literal: true

module Sources
  class ContextualPermission < GraphQL::Dataloader::Source
    # @return [User, AnonymousUser]
    attr_reader :user

    # @param [User, AnonymousUser] user
    def initialize(user)
      @user = user || AnonymousUser.new
    end

    # @param [<HierarchicalEntity>] entities
    def fetch(entities)
      permissions = {}

      ContextualPermission.scope_to(@user, entities).find_each do |record|
        permissions[record.entity_id] = record
      end

      entities.each do |entity|
        # :nocov:
        permissions[entity.id] ||= ContextualPermission.empty_permission_for(@user, entity)
        # :nocov:
      end

      entities.map { |entity| permissions[entity.id] }
    end
  end
end
