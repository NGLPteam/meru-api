# frozen_string_literal: true

RSpec.describe Types::HarvestScheduleModeType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :harvest_schedule_mode
end
