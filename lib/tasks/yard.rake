# frozen_string_literal: true

begin
  require "yard"
  require "yard/rake/yardoc_task"

  YARD::Rake::YardocTask.new do |t|
    t.files = [
      "lib/namespaces/**/*.rb",
      "app/**/*.rb",
      "lib/global_types/**/*.rb",
      "lib/variable_precision_date.rb",
      "-",
      "README.md",
      "LICENSE"
    ]

    t.options = [
      "--tag", "request_action:Request Action",
      "--tag", "operation:Operation",
      "--name-tag", "subsystem:Subsystem",
      "--embed-mixin", "AnonymousInterface",
      "--embed-mixin", "ClassMethods",
      "--transitive-tag", "subsystem",
      "--private",
      "--protected",
      "-m", "markdown",
      "--plugin", "activesupport-concern",
      "--exclude", "app/services/schemas/static/generator.rb",
      "--exclude", "app/services/testing",
      "--exclude", "app/services/tus_client.rb",
    ]

    t.stats_options = ["--list-undoc"]
  end
rescue LoadError
  # This space intentionally left blank
end
