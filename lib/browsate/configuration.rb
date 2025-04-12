# frozen_string_literal: true

require "logger"

module Browsate
  class Configuration
    attr_accessor :chrome_path, :chrome_args, :user_agent, :viewport_width, :viewport_height,
                  :session_dir, :debug, :timeout, :logger

    def initialize
      @chrome_path = ENV["CHROME_PATH"] || default_chrome_path
      @chrome_args = [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-dev-shm-usage",
        "--disable-accelerated-2d-canvas",
        "--disable-gpu",
        "--window-size=1280,800"
      ]
      @user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36"
      @viewport_width = 1280
      @viewport_height = 800
      @session_dir = File.join(Dir.pwd, "tmp")
      @debug = false
      @timeout = 30
      @logger = Logger.new($stdout)
      @logger.level = Logger::INFO
    end

    private

    def default_chrome_path
      paths = [
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", # macOS
        "/usr/bin/google-chrome",                                       # Linux
        "C:/Program Files/Google/Chrome/Application/chrome.exe",        # Windows
        "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"   # Windows 32-bit
      ]
      paths.find { |path| File.exist?(path) }
    end
  end
end
