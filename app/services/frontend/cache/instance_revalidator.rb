# frozen_string_literal: true

module Frontend
  module Cache
    # A service that talks to the Meru frontend in order to revalidate
    # the _entire instance_. This can only be manually invoked, since
    # it is rare we want to do this.
    #
    # @see Frontend::Cache::RevalidateInstance
    class InstanceRevalidator < AbstractRevalidator
      kind "instance"

      uri_path! "/api/revalidate/instance"
    end
  end
end
