# Testing RailsHealthChecker Gem

## 1. Basic Functionality Test
```bash
cd rails_health_monitor
ruby simple_test.rb
```

## 2. Test in Existing Rails App

### Add to Gemfile:
```ruby
gem 'rails_health_monitor', path: '/path/to/rails_health_monitor'
```

### Run bundle:
```bash
bundle install
```

### Test rake tasks:
```bash
rake health:check
rake health:gems
rake health:database
```

### Test HTTP endpoint:
```bash
# Start Rails server
rails server

# Test health endpoint
curl http://localhost:3000/health
```

## 3. Test with FinaSync Project

```bash
cd /Users/arshdeepsingh/Desktop/personal/PROJECTS/FinaSync/FinaSync-rails

# Add gem to Gemfile
echo "gem 'rails_health_monitor', path: '../rails_health_monitor'" >> Gemfile

# Install
bundle install

# Test
rake health:check
```

## 4. RSpec Tests
```bash
cd rails_health_monitor
bundle install
bundle exec rspec
```

## Expected Output:
- ✓ Version information
- ✓ Rails/Ruby version checks  
- ✓ Database connectivity
- ✓ Gem dependency analysis
- ✓ HTTP health endpoint (200 OK)