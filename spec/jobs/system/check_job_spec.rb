# frozen_string_literal: true

RSpec.describe System::CheckJob, type: :job do
  it_behaves_like "a void operation job", "system.check"
end
