# frozen_string_literal: true

class MeruConfig < ApplicationConfig
  attr_config tenant_id: "meru", tenant_name: "Meru", include_testing_schemas: false, serialize_rendering: false,
    experimental_dataloader: false, pool_size: 20, log_slow_fields: false, validate_graphql_query: true,
    disable_layout_preloading: false, disable_record_preloading: false,
    auto_approve_depositors: false,
    contributor_claimable: true,
    contributor_owner_updatable: true

  attr_config :new_relic_license_key

  coerce_types experimental_dataloader: :boolean, include_testing_schemas: :boolean, serialize_rendering: :boolean,
    pool_size: :integer, log_slow_fields: :boolean, validate_graphql_query: :boolean, disable_layout_preloading: :boolean,
    disable_record_preloading: :boolean, auto_approve_depositors: :boolean,
    contributor_claimable: :boolean, contributor_owner_updatable: :boolean

  def record_preloading_enabled? = !disable_record_preloading?

  def layout_preloading_enabled? = !disable_layout_preloading?
end
