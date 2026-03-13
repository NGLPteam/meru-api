# frozen_string_literal: true

RSpec.describe Types::DepositorAgreementStateType, type: :graphql_enum do
  it_behaves_like "a database-backed graphql enum", :depositor_agreement_state
end
