# frozen_string_literal: true

module Browsate
  class Browser
    attr_reader :browser, :session_id, :session_path, :console_logs

    def initialize
      @session_id = nil
      @session_path = nil
      @browser = nil
      @console_logs = []
    end

    def navigate(url, session_id = nil)
      setup_session(session_id)
      start_browser

      Browsate.logger.info("Navigating to #{url}")
      @browser.navigate_to(url)
      wait_for_page_load
      capture_state("initial")

      self
    end

    def execute_javascript(script)
      ensure_browser_ready
      Browsate.logger.info("Executing JavaScript")
      result = @browser.execute_script(script)
      capture_state("after_script")
      result
    end

    def close
      return unless @browser

      Browsate.logger.info("Closing browser session")
      @browser.stop
      @browser = nil
    end

    def wait_for_selector(selector, timeout = Browsate.configuration.timeout)
      ensure_browser_ready
      Browsate.logger.info("Waiting for selector: #{selector}")
      start_time = Time.now

      while Time.now - start_time < timeout
        element = @browser.find_element(selector)
        return element if element

        sleep 0.1
      end

      raise "Timeout waiting for selector: #{selector}"
    end

    def screenshot(path = nil)
      ensure_browser_ready
      path ||= File.join(@session_path, "screenshot_#{Time.now.to_i}.png")
      Browsate.logger.info("Taking screenshot: #{path}")
      @browser.screenshot(path)
      path
    end

    def html
      ensure_browser_ready
      @browser.execute_script("document.documentElement.outerHTML")
    end

    private

    def setup_session(session_id = nil)
      @session_id = session_id || "session_#{SecureRandom.hex(8)}"
      
      # Ensure the base session directory exists
      FileUtils.mkdir_p(Browsate.configuration.session_dir) unless Dir.exist?(Browsate.configuration.session_dir)
      
      @session_path = File.join(Browsate.configuration.session_dir, @session_id)
      
      # Create session directory
      FileUtils.mkdir_p(@session_path)
      Browsate.logger.info("Session path: #{@session_path}")
      
      # Create cookies directory for the session
      FileUtils.mkdir_p(File.join(@session_path, "cookies"))
    end

    def start_browser
      close if @browser

      Browsate.logger.info("Starting browser")

      Chromate.configure do |config|
        config.user_data_dir = File.join(@session_path, "cookies")
        config.headless = !Browsate.configuration.debug
        config.user_agent = Browsate.configuration.user_agent
      end

      @browser = Chromate::Browser.new
      @browser.start

      setup_console_capture
    end

    def setup_console_capture
      # We'll simulate console capturing since Chromate doesn't expose this directly
      @console_logs = []

      # Inject a script to capture console logs
      script = <<~JS
        window.addEventListener('error', function(event) {
          window.__browsate_errors = window.__browsate_errors || [];
          window.__browsate_errors.push({
            message: event.message,
            timestamp: new Date().toISOString()
          });
        });

        (function() {
          window.__browsate_logs = window.__browsate_logs || [];
        #{"  "}
          var originalConsole = {
            log: console.log,
            warn: console.warn,
            error: console.error,
            info: console.info
          };
        #{"  "}
          console.log = function() {
            window.__browsate_logs.push({
              type: 'log',
              message: Array.from(arguments).join(' '),
              timestamp: new Date().toISOString()
            });
            originalConsole.log.apply(console, arguments);
          };
        #{"  "}
          console.warn = function() {
            window.__browsate_logs.push({
              type: 'warn',
              message: Array.from(arguments).join(' '),
              timestamp: new Date().toISOString()
            });
            originalConsole.warn.apply(console, arguments);
          };
        #{"  "}
          console.error = function() {
            window.__browsate_logs.push({
              type: 'error',
              message: Array.from(arguments).join(' '),
              timestamp: new Date().toISOString()
            });
            originalConsole.error.apply(console, arguments);
          };
        #{"  "}
          console.info = function() {
            window.__browsate_logs.push({
              type: 'info',
              message: Array.from(arguments).join(' '),
              timestamp: new Date().toISOString()
            });
            originalConsole.info.apply(console, arguments);
          };
        })();
      JS

      @browser.execute_script(script)
    end

    def wait_for_page_load
      # Wait a short period for the page to load
      sleep 1
    rescue StandardError => e
      Browsate.logger.warn("Error waiting for page load: #{e.message}")
    end

    def ensure_browser_ready
      raise "Browser not initialized. Call navigate first." unless @browser
    end

    def capture_state(stage)
      timestamp = Time.now.to_i

      # Save current HTML
      html_content = html
      html_path = File.join(@session_path, "#{stage}_#{timestamp}_source.html")
      File.write(html_path, html_content)

      # Save current DOM state
      dom_path = File.join(@session_path, "#{stage}_#{timestamp}_dom.json")
      dom_json = @browser.execute_script(<<~JS)
        JSON.stringify({#{" "}
          title: document.title,
          url: window.location.href,
          bodySize: document.body ? document.body.innerHTML.length : 0
        })
      JS
      File.write(dom_path, dom_json)

      # Take screenshot
      screenshot(File.join(@session_path, "#{stage}_#{timestamp}_screenshot.png"))

      # Collect and save console logs
      @browser.execute_script(<<~JS)
        return JSON.stringify(window.__browsate_logs || []);
      JS
              .then do |logs_json|
        logs = JSON.parse(logs_json)
        @console_logs.concat(logs)

        logs_path = File.join(@session_path, "#{stage}_#{timestamp}_console.json")
        File.write(logs_path, JSON.pretty_generate(@console_logs))
      end
    end
  end
end
