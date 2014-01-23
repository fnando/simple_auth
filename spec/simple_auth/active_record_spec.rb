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

      SimpleAuth::Config.credentials.should == ["uid"]
    end

    it "should automatically set model" do
      model.authentication do |config|
        config.model = nil
      end

      SimpleAuth::Config.model.should == model_name
    end
  end

  context "new record" do
    before do
      subject.should_not be_valid
    end

    it "should require password" do
      subject.errors[:password].should_not be_empty
    end

    it "should require password to be at least 4-chars long" do
      subject.password = "123"
      subject.should_not be_valid
      subject.errors[:password].should_not be_empty
    end

    it "should require password confirmation" do
      user = User.create(password: "test", password_confirmation: "invalid")
      user.errors[:password_confirmation].should_not be_empty
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
      user.errors[:password].should_not be_empty
    end

    it "should authenticate using email" do
      model.authenticate("john@doe.com", "test").should == subject
    end

    it "should authenticate using login" do
      model.authenticate("johndoe", "test").should == subject
    end

    it "should authenticate using custom attribute" do
      SimpleAuth::Config.credentials = [:username]
      model.authenticate("john", "test").should == subject
    end

    it "should not authenticate using invalid credential" do
      model.authenticate("invalid", "test").should be_nil
    end

    it "should not authenticate using wrong password" do
      model.authenticate("johndoe", "invalid").should_not be
    end

    it "should return nil when no user has been found" do
      model.find_by_credential("invalid").should be_nil
    end

    it "should raise error when no user has been found" do
      expect {
        model.find_by_credential!("invalid")
      }.to raise_error(SimpleAuth::RecordNotFound)
    end

    it "should return user" do
      model.find_by_credential(subject.email).should == subject
      model.find_by_credential!(subject.email).should == subject
    end
  end
end
