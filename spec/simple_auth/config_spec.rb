require "spec_helper"

describe SimpleAuth::Config do
  it "should yield SimpleAuth::Config class" do
    SimpleAuth.setup do |config|
      config.should == SimpleAuth::Config
    end
  end

  it "should use [:email, :login] as credential attributes" do
    SimpleAuth::Config.credentials.should == [:email, :login]
  end

  it "should use User as default model" do
    SimpleAuth::Config.model.should == :user
  end

  specify "wipeout session should be disabled" do
    SimpleAuth::Config.wipeout_session.should be_false
  end
end
