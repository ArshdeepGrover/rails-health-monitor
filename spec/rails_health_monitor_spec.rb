require "spec_helper"

RSpec.describe RailsHealthMonitor do
  it "has a version number" do
    expect(RailsHealthMonitor::VERSION).not_to be nil
  end

  describe ".check" do
    it "returns health check results" do
      # Mock Rails and ActiveRecord for testing
      allow(Rails).to receive(:version).and_return("7.0.0")
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :active?).and_return(true)
      
      results = RailsHealthMonitor.check
      expect(results).to be_a(Hash)
      expect(results).to have_key(:rails_version)
      expect(results).to have_key(:database)
    end
  end
end