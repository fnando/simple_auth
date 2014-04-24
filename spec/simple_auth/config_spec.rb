require "spec_helper"

describe SimpleAuth::Config do
  it "should yield SimpleAuth::Config class" do
    SimpleAuth.setup do |config|
      expect(config).to eq(SimpleAuth::Config)
    end
  end

  it "should use [:email, :login] as credential attributes" do
    expect(SimpleAuth::Config.credentials).to eq([:email, :login])
  end

  it "should use User as default model" do
    expect(SimpleAuth::Config.model).to eq(:user)
  end

  specify "wipeout session should be disabled" do
    expect(SimpleAuth::Config.wipeout_session).to be_falsey
  end
end
