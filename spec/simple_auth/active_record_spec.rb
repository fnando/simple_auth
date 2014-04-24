require "spec_helper"

describe SimpleAuth::ActiveRecord do
  let(:model) { User }
  let(:model_name) { :user }
  subject { model.new }

  before do
    SimpleAuth::Config.model = model_name
  end

  context "configuration" do
    it "should set credentials" do
      model.authentication do |config|
        config.credentials = ["uid"]
      end

      expect(SimpleAuth::Config.credentials).to eq(["uid"])
    end

    it "should automatically set model" do
      model.authentication do |config|
        config.model = nil
      end

      expect(SimpleAuth::Config.model).to eq(model_name)
    end
  end

  context "new record" do
    before do
      expect(subject).not_to be_valid
    end

    it "should require password" do
      expect(subject.errors[:password]).not_to be_empty
    end

    it "should require password to be at least 4-chars long" do
      subject.password = "123"
      expect(subject).not_to be_valid
      expect(subject.errors[:password]).not_to be_empty
    end

    it "should require password confirmation" do
      user = User.create(password: "test", password_confirmation: "invalid")
      expect(user.errors[:password_confirmation]).not_to be_empty
    end
  end

  context "existing record" do
    before do
      model.delete_all
      model.create(
        :email => "john@doe.com",
        :login => "johndoe",
        :password => "test",
        :password_confirmation => "test",
        :username => "john"
      )
    end

    subject { model.first }

    it "should require password" do
      user = User.create(password: nil)
      expect(user.errors[:password]).not_to be_empty
    end

    it "should authenticate using email" do
      expect(model.authenticate("john@doe.com", "test")).to eq(subject)
    end

    it "should authenticate using login" do
      expect(model.authenticate("johndoe", "test")).to eq(subject)
    end

    it "should authenticate using custom attribute" do
      SimpleAuth::Config.credentials = [:username]
      expect(model.authenticate("john", "test")).to eq(subject)
    end

    it "should not authenticate using invalid credential" do
      expect(model.authenticate("invalid", "test")).to be_nil
    end

    it "should not authenticate using wrong password" do
      expect(model.authenticate("johndoe", "invalid")).not_to be
    end

    it "should return nil when no user has been found" do
      expect(model.find_by_credential("invalid")).to be_nil
    end

    it "should raise error when no user has been found" do
      expect {
        model.find_by_credential!("invalid")
      }.to raise_error(SimpleAuth::RecordNotFound)
    end

    it "should return user" do
      expect(model.find_by_credential(subject.email)).to eq(subject)
      expect(model.find_by_credential!(subject.email)).to eq(subject)
    end
  end
end
