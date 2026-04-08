# Run using bin/ci

CI.run do
  step "Setup", "bin/setup --skip-server"
  step "Style: Ruby", "bin/rubocop"
  step "Tests: Rails", "bin/rails test"
end
