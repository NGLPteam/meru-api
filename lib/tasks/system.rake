# frozen_string_literal: true

namespace :system do
  desc "Reprocess all layouts"
  task reprocess_layouts: :environment do
    Rails.logger.level = 0

    MeruAPI::Container["system.reprocess_layouts"].().value!
  end

  desc "Vacuum the database asynchronously"
  task vacuum_full: :environment do
    System::VacuumFullJob.perform_later
  end
end
