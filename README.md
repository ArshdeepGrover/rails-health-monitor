# RailsHealthChecker

A comprehensive health checking gem for Ruby on Rails applications and their dependencies.

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

The gem automatically adds a `/health` endpoint with a comprehensive web dashboard:

```bash
# Visit in browser
http://localhost:3000/health
```

**Dashboard Features:**
- 🏥 Visual health overview with status indicators
- 📊 Real-time health score (0-100)
- 🔧 System information (Rails/Ruby versions)
- 💾 Database connectivity status
- 📦 Gem dependencies analysis
- 🔒 Security vulnerability overview
- 🎯 Priority actions with color-coded urgency
- 🔄 Auto-refresh every 30 seconds

## Configuration

The gem works out of the box with minimal configuration. The health middleware is automatically added to your Rails application.

## Development

After checking out the repo, run:

```bash
bundle install
```

To run tests:

```bash
bundle exec rspec
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).