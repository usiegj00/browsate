# frozen_string_literal: true

RSpec.describe Browsate::Browser do
  let(:browser) { Browsate.browser }

  after do
    browser.close
  end

  describe "#navigate" do
    it "navigates to a URL and captures state" do
      browser.navigate(test_url("form.html"))

      expect(browser.session_id).not_to be_nil
      expect(browser.session_path).to include(browser.session_id)

      # Check if state files were created
      state_files = Dir.glob(File.join(browser.session_path, "*"))
      expect(state_files).not_to be_empty

      # Verify we have HTML, screenshot and console outputs
      expect(state_files.any? { |f| f.include?("source.html") }).to be true
      expect(state_files.any? { |f| f.include?("screenshot.png") }).to be true
      expect(state_files.any? { |f| f.include?("dom.json") }).to be true
      expect(state_files.any? { |f| f.include?("console.json") }).to be true
    end
  end

  describe "#execute_javascript" do
    it "executes JavaScript and returns the result" do
      browser.navigate(test_url("form.html"))

      result = browser.execute_javascript("document.title")
      expect(result).to eq("Browsate Test Form")

      # Check if more state files were created after executing JS
      state_files = Dir.glob(File.join(browser.session_path, "*"))
      expect(state_files.any? { |f| f.include?("after_script") }).to be true
    end
  end

  describe "#html" do
    it "returns the current HTML of the page" do
      browser.navigate(test_url("form.html"))

      html = browser.html
      expect(html).to include("<title>Browsate Test Form</title>")
      expect(html).to include("<form id=\"testForm\">")
    end
  end

  describe "#wait_for_selector" do
    it "waits for a selector to be visible" do
      browser.navigate(test_url("dynamic.html"))

      # The content is initially hidden and appears after 2 seconds
      browser.wait_for_selector("#content")

      # After waiting, we should be able to get the element
      result = browser.execute_javascript("document.getElementById('content').style.display")
      expect(result).to eq("block")
    end
  end

  describe "session persistence" do
    it "maintains state between sessions" do
      # First session: Fill out form but don't submit
      browser.navigate(test_url("form.html"))
      session_id = browser.session_id

      browser.execute_javascript(<<~JS)
        document.getElementById('name').value = 'Test User';
        document.getElementById('email').value = 'test@example.com';
        document.getElementById('message').value = 'This is a test message';
      JS

      # Close browser and create a new one with the same session
      browser.close

      # Second session: Submit the form
      browser = Browsate::Browser.new
      browser.navigate(test_url("form.html"), session_id)

      # Verify the form values are still there
      name = browser.execute_javascript("document.getElementById('name').value")
      email = browser.execute_javascript("document.getElementById('email').value")
      message = browser.execute_javascript("document.getElementById('message').value")

      expect(name).to eq("Test User")
      expect(email).to eq("test@example.com")
      expect(message).to eq("This is a test message")

      # Submit the form
      browser.execute_javascript("document.getElementById('testForm').dispatchEvent(new Event('submit'))")

      # Check if the result is displayed
      browser.wait_for_selector("#result")
      result_display = browser.execute_javascript("document.getElementById('result').style.display")
      expect(result_display).to eq("block")

      # Verify localStorage persistence
      storage_data = browser.execute_javascript("localStorage.getItem('formSubmission')")
      expect(storage_data).not_to be_nil

      parsed_data = JSON.parse(storage_data)
      expect(parsed_data["name"]).to eq("Test User")
      expect(parsed_data["email"]).to eq("test@example.com")
    end
  end
end
