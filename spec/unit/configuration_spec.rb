# frozen_string_literal: true

RSpec.describe Browsate::Configuration do
  describe "defaults" do
    let(:config) { Browsate::Configuration.new }

    it "sets default chrome arguments" do
      expect(config.chrome_args).to include("--no-sandbox")
      expect(config.chrome_args).to include("--disable-gpu")
    end

    it "sets default viewport dimensions" do
      expect(config.viewport_width).to eq(1280)
      expect(config.viewport_height).to eq(800)
    end

    it "sets a default user agent" do
      expect(config.user_agent).to include("Mozilla")
      expect(config.user_agent).to include("Chrome")
    end

    it "sets a default session directory" do
      expect(config.session_dir).to include("tmp")
    end

    it "sets a default timeout" do
      expect(config.timeout).to eq(30)
    end

    it "sets a default logger level" do
      expect(config.logger.level).to eq(Logger::INFO)
    end
  end

  describe "#configure" do
    it "allows configuration via block" do
      Browsate.configure do |config|
        config.debug = true
        config.timeout = 60
        config.viewport_width = 1920
        config.viewport_height = 1080
      end

      expect(Browsate.configuration.debug).to be true
      expect(Browsate.configuration.timeout).to eq(60)
      expect(Browsate.configuration.viewport_width).to eq(1920)
      expect(Browsate.configuration.viewport_height).to eq(1080)
    end
  end
end
