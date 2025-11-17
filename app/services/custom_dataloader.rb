# frozen_string_literal: true

# Custom Dataloader that manages fiber state with connections for AR & GQL.
class CustomDataloader < GraphQL::Dataloader
  self.default_fiber_limit = 10

  self.default_nonblocking = false

  def get_fiber_variables
    vars = super

    # Collect the current connection config to pass on:
    vars[:connected_to] = {
      role: ActiveRecord::Base.current_role,
      shard: ActiveRecord::Base.current_shard,
      prevent_writes: ActiveRecord::Base.current_preventing_writes
    }

    vars
  end

  def set_fiber_variables(vars)
    connection_config = vars.delete(:connected_to)

    dry_effects_stack = vars.delete(:dry_effects_stack)

    Dry::Effects::Frame.stack = dry_effects_stack || Dry::Effects::Stack.new

    # Reset connection config from the parent fiber:
    ActiveRecord::Base.connecting_to(**connection_config)

    super
  end

  def cleanup_fiber
    super

    # Release the current connection
    ActiveRecord::Base.connection_pool.release_connection
  end
end
