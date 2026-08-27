# frozen_string_literal: true

require "test_helper"

class SidekiqRuntimeCompatibilityTest < ActiveSupport::TestCase
  test "Sidekiq process API used by the readiness probe loads explicitly" do
    require "sidekiq/api"

    assert defined?(Sidekiq::ProcessSet)
  end
end
