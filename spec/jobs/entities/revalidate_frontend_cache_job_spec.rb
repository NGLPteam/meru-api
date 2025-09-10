# frozen_string_literal: true

RSpec.describe Entities::RevalidateFrontendCacheJob, type: :job do
  let_it_be(:collection) { FactoryBot.create :collection }

  it_behaves_like "a pass-through operation job", "entities.revalidate_frontend_cache" do
    let(:job_arg) { collection }
  end
end
