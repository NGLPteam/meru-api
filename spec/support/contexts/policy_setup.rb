# frozen_string_literal: true

RSpec.shared_context "policy setup" do
  let_it_be(:admin, refind: true) { FactoryBot.create :user, :admin }

  let_it_be(:regular_user, refind: true) { FactoryBot.create :user }

  let_it_be(:anonymous_user) { AnonymousUser.new }

  let(:user) { regular_user }

  let(:context) { { user:, } }
end
