# Example usage in a Rails application

# 1. Add to Gemfile:
# gem 'rails_health_checker'

# 2. In your Rails application, you can use:

# Run complete health check
results = RailsHealthChecker.check

# Access specific health data
puts "Rails version: #{results[:rails_version][:current]}"
puts "Database status: #{results[:database][:status]}"
puts "Total gems: #{results[:gems][:total]}"

# Use rake tasks
# rake health:check
# rake health:gems  
# rake health:database

# Access health endpoint
# GET /health
# Returns JSON with health status