require "spec_helper"

describe SimpleAuth::Config do
  it "yields SimpleAuth::Config class" do
    SimpleAuth.setup do |config|
      expect(config).to eq(SimpleAuth::Config)
    end
  end

  it "uses [:email, :login] as credential attributes" do
    expect(SimpleAuth::Config.credentials).to eq([:email, :login])
  end

  it "uses User as default model" do
    expect(SimpleAuth::Config.model).to eq(:user)
  end

  it "disables session wipeout" do
    expect(SimpleAuth::Config.wipeout_session).to be_falsey
  end
end
