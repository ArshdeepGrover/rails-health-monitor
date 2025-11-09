module RailsHealthMonitor
  class Railtie < Rails::Railtie
    rake_tasks do
      load "rails_health_monitor/tasks.rb"
    end

    initializer "rails_health_monitor.add_middleware" do |app|
      app.middleware.use RailsHealthMonitor::DashboardMiddleware
    end
  end
end