require File.dirname(__FILE__) + "/../spec_helper"

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

  specify "crypter should expect 2 block arguments" do
    SimpleAuth::Config.crypter.arity.should == 2
  end

  specify "salt should expect 1 block argument" do
    SimpleAuth::Config.salt.arity.should == 1
  end

  specify "salt should return a 64-char long salt" do
    SimpleAuth::Config.salt.call(nil).size.should == 64
  end
end
