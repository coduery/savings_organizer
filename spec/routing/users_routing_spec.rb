require 'spec_helper'

describe "routes.db" do
  describe "get users/view" do
    it "route exists" do
      expect(get: "users/view").to be_routable
    end
  end

  describe "post users/view" do
    it "route exists" do
      expect(post: "users/view").to be_routable
    end
  end
end
