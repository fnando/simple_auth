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
    expect(@helper).to receive(:logged_in?).and_return(true)
    expect(@helper.when_logged { "logged" }).to eq("logged")
  end

  it "should not render block when user is unlogged" do
    expect(@helper).to receive(:logged_in?).and_return(false)
    expect(@helper.when_logged { "logged" }).to be_nil
  end
end
