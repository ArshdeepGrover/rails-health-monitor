# Commands Reference

## Development Commands

### Setup
```bash
bundle install
```

### Testing
```bash
bundle exec rspec
```

### Build
```bash
bundle exec rake build
```

## Release Process

### 1. Update Version
Edit `lib/rails_health_checker/version.rb`:
```ruby
VERSION = "x.x.x"
```

### 2. Update Changelog
Add changes to `CHANGELOG.md` (if exists) or document in commit message.

### 3. Commit Changes
```bash
git add .
git commit -m "Bump version to x.x.x"
```

### 4. Release
```bash
bundle exec rake release
```

This command will:
- Build the gem
- Create git tag
- Push tag to GitHub  
- Push gem to RubyGems.org

### Manual Release (if needed)
```bash
# Build
gem build rails-health-checker.gemspec

# Push to RubyGems
gem push rails-health-checker-x.x.x.gem

# Tag and push
git tag vx.x.x
git push origin vx.x.x
```

## Usage Commands

### Rake Tasks
```bash
rake health:check        # Complete health check
rake health:gems         # Check gem dependencies
rake health:database     # Check database connectivity
```

### Programmatic
```ruby
results = RailsHealthChecker.check
analyzer = RailsHealthChecker::GemAnalyzer.new
gem_health = analyzer.analyze
```

### HTTP Endpoint
```
GET /health              # Health dashboard
```

## Deployment Commands

### Deploy to RubyGems
```bash
# Login to RubyGems (first time only)
gem signin

# Deploy latest version
bundle exec rake release
```

### Deploy Documentation
```bash
# If using GitHub Pages
git push origin main

# If using Netlify (manual)
# Upload docs folder to Netlify dashboard

# If using custom server
scp -r docs/ user@server:/path/to/docs
```

### Verify Deployment
```bash
# Check gem is live
gem search rails-health-checker

# Test installation
gem install rails-health-checker
```

## Environment Variables
```bash
export HEALTH_USERNAME=your_username
export HEALTH_PASSWORD=your_secure_password
```