ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # This project uses DB views, so we keep tests in a single DB.
  # Do not enable parallel workers unless test DB cloning for views is handled.
end
