ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # This project uses DB views; keep single DB to avoid missing-view issues on cloned test DBs.
  parallelize(workers: 1)
end
