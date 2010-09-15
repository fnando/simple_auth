require "spec_helper"

describe SimpleAuth::Helper do
  before do
    @helper = Object.new
    @helper.class_eval { attr_accessor :output_buffer }
    @helper.extend(SimpleAuth::Helper)
    @helper.extend(ActionView::Helpers::CaptureHelper)
  end

  it "should include module" do
    ApplicationController.included_modules.include?(SimpleAuth::Helper)
  end

  it "should render block when user is logged" do
    @helper.should_receive(:logged_in?).and_return(true)
    @helper.when_logged { "logged" }.should == "logged"
  end

  it "should not render block when user is unlogged" do
    @helper.should_receive(:logged_in?).and_return(false)
    @helper.when_logged { "logged" }.should be_nil
  end
end
