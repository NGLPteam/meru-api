# frozen_string_literal: true

require "graphql/rake_task"

GraphQL::RakeTask.new(schema_name: "APISchema")
