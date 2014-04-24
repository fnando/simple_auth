require "spec_helper"

describe SimpleAuth::Helper do
  before do
    @helper = Object.new
    @helper.class_eval { attr_accessor :output_buffer }
    @helper.extend(SimpleAuth::Helper)
    @helper.extend(ActionView::Helpers::CaptureHelper)
  end

  it "includes module" do
    ApplicationController.included_modules.include?(SimpleAuth::Helper)
  end

  it "renders block when user is logged" do
    expect(@helper).to receive(:logged_in?).and_return(true)
    expect(@helper.when_logged { "logged" }).to eq("logged")
  end

  it "doesn't render block when user is unlogged" do
    expect(@helper).to receive(:logged_in?).and_return(false)
    expect(@helper.when_logged { "logged" }).to be_nil
  end
end
