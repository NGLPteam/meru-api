# frozen_string_literal: true

module MeruPitchfork
  WEB_CONCURRENCY = ENV.fetch("WEB_CONCURRENCY", Etc.nprocessors).to_i

  # Double the number of processes to provide better throughput in DO
  # WEB_CONCURRENCY=2 would result in 4 processes
  BASE_PROCS = WEB_CONCURRENCY * 2

  # Ensure there is always at least 1 process (dev uses WEB_CONCURRENCY=0)
  PROCESS_COUNT = BASE_PROCS.clamp(1, 12)

  PORT = ENV.fetch("PORT", 8080).to_i
end

worker_processes MeruPitchfork::PROCESS_COUNT

listen MeruPitchfork::PORT, tcp_nopush: true, reuseport: true

timeout 60

max_consecutive_spawn_errors 5

# Should improve performance
rewindable_input false

refork_after [50, 100, 1000]

before_fork do |server|
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.connection.disconnect!
  end
end

after_worker_fork do |server, worker|
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end

after_mold_fork do |server, mold|
  Process.warmup
end
