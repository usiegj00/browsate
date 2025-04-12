# frozen_string_literal: true

# Mock implementation of Chromate for testing
module Chromate
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end
  end

  class Configuration
    attr_accessor :user_data_dir, :headless, :user_agent, :native_control, :proxy

    def initialize
      @user_data_dir = nil
      @headless = true
      @user_agent = nil
      @native_control = false
      @proxy = nil
    end
  end

  class Browser
    def initialize(options = {})
      @options = options
      @started = false
      @url = nil
    end

    def start
      @started = true
      puts "Mock Chromate Browser started with options: #{@options}" if ENV["DEBUG"]
      self
    end

    def stop
      @started = false
      puts "Mock Chromate Browser stopped" if ENV["DEBUG"]
      self
    end

    def navigate_to(url)
      raise "Browser not started" unless @started

      @url = url
      puts "Mock Chromate Browser navigated to: #{url}" if ENV["DEBUG"]
      self
    end

    def execute_script(script)
      raise "Browser not started" unless @started

      puts "Evaluating JavaScript: #{script[0..50]}..." if ENV["DEBUG"]

      # Return mock values based on script content
      if script.include?("document.title")
        "Browsate Test Form"
      elsif script.include?("document.querySelector('h1')") && script.include?("textContent")
        "Test Form"
      elsif script.include?("document.documentElement.outerHTML")
        generate_html
      elsif script.include?("window.__browsate_logs")
        # For console logs capture
        "[]"
      elsif script.include?("document.getElementById('result').style.display")
        "block"
      elsif script.include?("document.getElementById('content').style.display")
        "block"
      elsif script.include?("document.getElementById('name').value = 'CLI Test'")
        "Form filled"
      elsif script.include?("getElementById('name').value")
        "Test User"
      elsif script.include?("document.getElementById('name').value")
        "CLI Test"
      elsif script.include?("getElementById('email').value")
        "test@example.com"
      elsif script.include?("getElementById('message').value")
        "This is a test message"
      elsif script.include?("localStorage.getItem('formSubmission')")
        '{"name":"Test User","email":"test@example.com","message":"This is a test message","timestamp":"2025-04-12T12:00:00.000Z"}'
      elsif script.include?("JSON.stringify(")
        '{"title":"Browsate Test Form","url":"http://localhost:8889/form.html","bodySize":1234}'
      else
        "Mock result for: #{script[0..20]}..."
      end
    end

    def then
      yield execute_script("") if block_given?
    end

    def find_element(selector)
      raise "Browser not started" unless @started

      puts "Finding element: #{selector}" if ENV["DEBUG"]

      # Return a simple element object for most selectors
      # but return nil initially for content to test wait_for_selector
      if selector == "#content" && @content_requested_count.nil?
        @content_requested_count = 1
        nil
      else
        @content_requested_count = 2 if selector == "#content"
        MockElement.new(selector)
      end
    end

    def screenshot(path)
      raise "Browser not started" unless @started

      # Create an empty file
      FileUtils.touch(path)
      puts "Screenshot saved to: #{path}" if ENV["DEBUG"]
      path
    end

    private

    def generate_html
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>Browsate Test Form</title>
        </head>
        <body>
          <h1>Test Form</h1>
          <form id="testForm">
            <div>
              <label for="name">Name:</label>
              <input type="text" id="name" name="name" value="Test User">
            </div>
            <div>
              <label for="email">Email:</label>
              <input type="email" id="email" name="email" value="test@example.com">
            </div>
            <div>
              <label for="message">Message:</label>
              <textarea id="message" name="message">This is a test message</textarea>
            </div>
            <button type="submit">Submit</button>
          </form>
          <div id="result" style="display: block;">
            <h2>Form Submission Result</h2>
            <pre id="formData">{"name":"Test User","email":"test@example.com","message":"This is a test message"}</pre>
          </div>
          <div id="content" style="display: block;">Dynamic content</div>
        </body>
        </html>
      HTML
    end
  end

  class MockElement
    attr_reader :selector

    def initialize(selector)
      @selector = selector
    end

    def click
      puts "Clicked on #{@selector}" if ENV["DEBUG"]
      true
    end

    def type(text)
      puts "Typed '#{text}' into #{@selector}" if ENV["DEBUG"]
      true
    end
  end
end

# Required for our mock classes
require "ostruct"
require "fileutils"
require "json"

# Initialize default configuration
Chromate.configure {}
