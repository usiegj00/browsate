# Browsate

Browsate is a Ruby gem for automating Chrome browser interactions using the Chrome DevTools Protocol (CDP) via Chromate. It allows you to navigate to pages, execute JavaScript, and maintain session state between runs.

## Features

- Navigate to web pages using a Chrome browser
- Execute JavaScript in the context of the page
- Maintain session state (cookies, localStorage, etc.) between runs
- Capture browser state (HTML, DOM, screenshots, console logs)
- Command-line interface

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'browsate'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install browsate
```

## Usage

### Command Line

```bash
# Navigate to a URL
$ browsate visit https://example.com

# Execute JavaScript on the page
$ browsate visit https://example.com --script "document.querySelector('h1').textContent"

# Execute JavaScript from a file
$ browsate visit https://example.com --script ./scripts/my-script.js

# Wait for an element before executing
$ browsate visit https://example.com --wait "h1" --script "document.querySelector('h1').textContent"

# Use an existing session (e.g., for form submissions after initial page load)
$ browsate visit https://example.com
# Note the session ID output (e.g., session_abc123)
$ browsate exec session_abc123 "document.querySelector('form').submit()"

# Take a screenshot of a session
$ browsate screenshot session_abc123
```

### Ruby API

```ruby
require 'browsate'

# Configure Browsate
Browsate.configure do |config|
  config.debug = true
  config.session_dir = "/path/to/sessions"
end

# Navigate to a page
browser = Browsate.browser
browser.navigate("https://example.com")

# Execute JavaScript
result = browser.execute_javascript("document.querySelector('h1').textContent")
puts result

# Get current HTML
html = browser.html
puts html

# Take a screenshot
browser.screenshot("/path/to/screenshot.png")

# Close the browser
browser.close
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## License

Copyright (c) 2025 Jonathan Siegel. All rights reserved.