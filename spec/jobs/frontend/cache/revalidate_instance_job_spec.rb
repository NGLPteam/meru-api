# frozen_string_literal: true

RSpec.describe Frontend::Cache::RevalidateInstanceJob, type: :job do
  it_behaves_like "a void operation job", "frontend.cache.revalidate_instance"
end
