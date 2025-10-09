# frozen_string_literal: true

class FrontendConfig < ApplicationConfig
  attr_config :revalidate_secret

  COMMUNITY_PATH_TEMPLATE = "/communities/%<system_slug>s"
  COLLECTION_PATH_TEMPLATE = "/collections/%<system_slug>s"
  ITEM_PATH_TEMPLATE = "/items/%<system_slug>s"

  # @param [HierarchicalEntity] entity
  # @return [String]
  def entity_path_for(entity)
    params = { system_slug: entity.system_slug }

    case entity
    when Community
      COMMUNITY_PATH_TEMPLATE % params
    when Collection
      COLLECTION_PATH_TEMPLATE % params
    when Item
      ITEM_PATH_TEMPLATE % params
    else
      # :nocov:
      raise "Unsupported entity type: #{entity.class.name}"
      # :nocov:
    end
  end

  # @param [HierarchicalEntity] entity
  # @return [String]
  def entity_url_for(entity)
    base_url = LocationsConfig.frontend_request

    URI.join(base_url, entity_path_for(entity)).to_s
  end
end
