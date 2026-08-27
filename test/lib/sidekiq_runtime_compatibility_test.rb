# frozen_string_literal: true

require "test_helper"
require "connection_pool"

class SidekiqRuntimeCompatibilityTest < ActiveSupport::TestCase
  test "connection pool accepts Sidekiq's positional timeout" do
    timeout_parameter = ConnectionPool::TimedStack.instance_method(:pop).parameters.first

    assert_equal [ :opt, :timeout ], timeout_parameter
  end

  test "Sidekiq process API used by the readiness probe loads explicitly" do
    require "sidekiq/api"

    assert defined?(Sidekiq::ProcessSet)
  end
end
