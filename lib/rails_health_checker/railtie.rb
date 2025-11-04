module RailsHealthChecker
  class Railtie < Rails::Railtie
    rake_tasks do
      load "rails_health_checker/tasks.rb"
    end

    initializer "rails_health_checker.add_middleware" do |app|
      app.middleware.use RailsHealthChecker::DashboardMiddleware
    end
  end
end