require 'spec_helper'

describe "entries routes" do
  
  describe "get deduct" do
    it "routes to entries/deduct" do
      { get: "/entries/deduct" }.should be_routable
    end
  end
  
end
