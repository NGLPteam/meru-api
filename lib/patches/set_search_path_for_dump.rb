# frozen_string_literal: true

require "active_record/tasks/postgresql_database_tasks"

module Patches
  module SetSearchPathForDump
    def structure_dump(filename, extra_flags)
      super
    ensure
      # ::Support::System["column_cache.write"].call.value!
    end
  end
end

ActiveRecord::Tasks::PostgreSQLDatabaseTasks.prepend Patches::SetSearchPathForDump
