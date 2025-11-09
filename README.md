# RailsHealthChecker

[![Gem Version](https://badge.fury.io/rb/rails-health-checker.svg)](https://badge.fury.io/rb/rails-health-checker)
[![Documentation](https://img.shields.io/badge/docs-rails--health--checker.netlify.app-blue)](https://rails-health-checker.netlify.app)
[![GitHub](https://img.shields.io/github/license/ArshdeepGrover/rails-health-checker)](https://github.com/ArshdeepGrover/rails-health-checker/blob/main/LICENSE)

A comprehensive health checking gem for Ruby on Rails applications and their dependencies.

🌐 **[Live Documentation & Demo](https://rails-health-checker.netlify.app)**

## Features

- **Rails Version Check**: Validates Rails version compatibility
- **Ruby Version Check**: Ensures Ruby version is supported
- **Database Connectivity**: Tests database connection health
- **Gem Dependencies**: Analyzes gem health and outdated packages
- **Security Vulnerabilities**: Checks for known security issues
- **HTTP Health Endpoint**: Provides `/health` endpoint for monitoring
- **Rake Tasks**: Command-line health checking tools

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-health-checker'
```

And then execute:

```bash
bundle install
```

Or install it directly:

```bash
gem install rails-health-checker
```

## Usage

### Programmatic Usage

```ruby
# Run complete health check
results = RailsHealthChecker.check

# Check specific components
analyzer = RailsHealthChecker::GemAnalyzer.new
gem_health = analyzer.analyze
```

### Rake Tasks

```bash
# Complete health check
rake health:check

# Check gem dependencies only
rake health:gems

# Check database connectivity
rake health:database
```

### HTTP Health Dashboard

The gem automatically adds protected `/health` endpoints with comprehensive web dashboards:

```bash
# Main dashboard (requires authentication)
http://localhost:3000/health
```

**Authentication:**
- Default: username `admin`, password `health123`
- Custom: Set `HEALTH_USERNAME` and `HEALTH_PASSWORD` environment variables

**Dashboard Features:**
- 🏥 Visual health overview with status indicators
- 📊 Real-time health score (0-100)
- 🔧 System information (Rails/Ruby versions)
- 💾 Database connectivity status
- 📦 Gem dependencies analysis
- 🔒 Security vulnerability overview with detailed list
- 🎯 Priority actions with color-coded urgency
- 🔄 Auto-refresh every 30 seconds
- 🔐 Password-protected access

## Configuration

The gem works out of the box with minimal configuration. The health middleware is automatically added to your Rails application.

### Authentication Configuration

```bash
# Set custom credentials (optional)
export HEALTH_USERNAME=your_username
export HEALTH_PASSWORD=your_secure_password
```

**Default credentials:**
- Username: `admin`
- Password: `health123`

### Manual Middleware Setup (if needed)

If the middleware doesn't load automatically, add to `config/application.rb`:

```ruby
require 'rails_health_checker'

class Application < Rails::Application
  config.middleware.use RailsHealthChecker::DashboardMiddleware
end
```

## Development

After checking out the repo, run:

```bash
bundle install
```

To run tests:

```bash
bundle exec rspec
```

### Building and Publishing

To build the gem:

```bash
bundle exec rake build
```

To release a new version:

```bash
bundle exec rake release
```

This will:
1. Build the gem
2. Create a git tag for the version
3. Push the tag to GitHub
4. Push the gem to RubyGems.org

## Links

- 🌐 **[Documentation & Demo](https://rails-health-checker.netlify.app)**
- 📦 **[RubyGems](https://rubygems.org/gems/rails-health-checker)**
- 🐙 **[GitHub Repository](https://github.com/ArshdeepGrover/rails-health-checker)**
- 🐛 **[Issue Tracker](https://github.com/ArshdeepGrover/rails-health-checker/issues)**

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

---

**Made with ❤️ by [Arshdeep Singh](https://github.com/ArshdeepGrover)**