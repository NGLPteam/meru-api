# frozen_string_literal: true

class MeruConfig < ApplicationConfig
  attr_config tenant_id: "meru", tenant_name: "Meru", include_testing_schemas: false, serialize_rendering: false,
    experimental_dataloader: false, pool_size: 20

  coerce_types experimental_dataloader: :boolean, include_testing_schemas: :boolean, serialize_rendering: :boolean
end
