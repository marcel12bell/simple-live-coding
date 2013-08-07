require 'spec_helper'

describe RubyDraw do
  let(:app) { RubyDraw.new :title => "app" }

  describe "app" do
    it "should open window" do 
      $app.width.should == 700
    end
  end

end
