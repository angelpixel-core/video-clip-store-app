require "capybara/rspec"
require "selenium-webdriver"

Capybara.default_max_wait_time = 5
Capybara.server_host = "127.0.0.1"
Capybara.app_host = "http://127.0.0.1"

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.binary = ENV["CHROME_BIN"] || [ "/usr/bin/chromium-browser", "/usr/bin/chromium", "/usr/bin/google-chrome" ].find { |path| File.exist?(path) }
  options.add_argument("--headless=new")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")

  chromedriver_path = ENV["CHROMEDRIVER_PATH"] || [ "/usr/bin/chromedriver", "/usr/lib/chromium/chromedriver", "/usr/bin/chromium-chromedriver" ].find { |path| File.exist?(path) }
  service = Selenium::WebDriver::Service.chrome(path: chromedriver_path) if chromedriver_path
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, service: service)
end
