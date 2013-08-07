require 'spec_helper'

describe StringObject do
  let(:app) { RubyDraw.new :title => "app" }

  describe "#append" do
    it "appends key to @content" do
      s_object = StringObject.new("")
      s_object.append("S")
      s_object.content.should == "S"
    end
  end
  
end