# frozen_string_literal: true

require "bundler/setup"
require "fileutils"
require "webrick"

# Set testing environment
ENV["TESTING"] = "true"
require "browsate"

# Start a WEBrick server for testing
TEST_PORT = ENV["TEST_PORT"] || 8889
TEST_SERVER = WEBrick::HTTPServer.new(
  Port: TEST_PORT.to_i,
  DocumentRoot: File.join(File.dirname(__FILE__), "fixtures", "html"),
  AccessLog: [],
  Logger: WEBrick::Log.new(File.join(File.dirname(__FILE__), "..", "tmp", "test_server.log"), WEBrick::Log::ERROR)
)

Thread.new { TEST_SERVER.start }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Configure Browsate for testing
  config.before(:all) do
    # Create test temp directory
    @test_tmp_dir = File.join(File.dirname(__FILE__), "..", "tmp", "test_#{Time.now.to_i}")
    FileUtils.mkdir_p(@test_tmp_dir)

    Browsate.configure do |config|
      config.session_dir = @test_tmp_dir
      config.logger.level = Logger::ERROR unless ENV["DEBUG"]
    end
  end

  config.after(:each) do
    # Reset browser after each test to ensure clean state
    Browsate.reset!
  end

  config.after(:all) do
    # Shut down the test server
    TEST_SERVER.shutdown
  end
end

def test_url(path)
  "http://localhost:#{TEST_PORT}/#{path}"
end
