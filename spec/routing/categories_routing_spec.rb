require 'spec_helper'

describe "categories routes" do

  describe "get view" do
    it "routes to categories/view" do
      { get: "categories/view" }.should be_routable;
    end
  end

  describe "post view" do
    it "routes to categories/view" do
      { post: "categories/view" }.should be_routable;
    end
  end

end
