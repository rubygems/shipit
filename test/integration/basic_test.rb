require 'test_helper'

class BasicTest < ActionDispatch::IntegrationTest
  test "root redirects to github auth" do
    get "/"
    assert_redirected_to "http://www.example.com/github/auth/github?origin=http%3A%2F%2Fwww.example.com%2F"
  end

  test "ping" do
    get "/status/version"
    assert_response 200
  end
end
