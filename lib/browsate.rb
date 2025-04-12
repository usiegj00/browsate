# frozen_string_literal: true

require "fileutils"
require "json"
require "securerandom"
require "zeitwerk"
require "chromate"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/chromate.rb")
loader.setup

module Browsate
  class Error < StandardError; end

  # Set up a singleton access point
  class << self
    def configure
      yield configuration if block_given?
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def browser
      @browser ||= Browser.new
    end

    def logger
      @logger ||= configuration.logger
    end

    def reset!
      @browser&.close
      @browser = nil
    end
  end
end
