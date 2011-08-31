ENV["RAILS_ENV"] = "test"
require "bundler"
Bundler.setup(:default, :development, :test)
Bundler.require

I18n.load_path += Dir[File.expand_path("../../locales/*.yml", __FILE__)]

require "rails"
require "simple_auth"
require File.dirname(__FILE__) + "/support/config/boot"
require "rspec/rails"
require "mongo_mapper"

# Load database schema
load File.dirname(__FILE__) + "/schema.rb"

# Set up MongoDB connection
MongoMapper.connection = Mongo::Connection.new("localhost")
MongoMapper.database = "simple_auth"

# Restore default configuration
RSpec.configure do |config|
  config.before :each do
    load File.dirname(__FILE__) + "/../lib/simple_auth/config.rb"
  end
end

shared_examples_for "orm" do
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

    it "should require password confirmation not to be empty" do
      subject.password_confirmation = ""
      subject.errors[:password_confirmation].should_not be_empty
    end

    it "should require password confirmation not to be nil" do
      subject.password_confirmation = nil
      subject.errors[:password_confirmation].should_not be_empty
    end

    it "should unset password after saving" do
      subject = model.new(:password => "test", :password_confirmation => "test")
      subject.save
      subject.password.should be_nil
      subject.password_confirmation.should be_nil
    end

    it "should mark password as changed" do
      subject = model.new(:password => "test")
      subject.password_changed?.should be_true
    end

    it "should not mark password as changed" do
      subject = model.new
      subject.password_changed?.should be_false
    end

    it "should mark password as unchanged after saving" do
      subject = model.new(:password => "test", :password_confirmation => "test")
      subject.save
      subject.password_changed?.should be_false
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

    it "should not require password when it hasn't changed" do
      subject.login = "john"
      subject.should be_valid
    end

    it "should require password when explicitly said so" do
      subject.require_password!
      subject.should_not be_valid
      subject.errors[:password].should_not be_empty
    end

    it "should require password" do
      subject.require_password?.should be_false
      subject.require_password!
      subject.require_password?.should be_true
    end

    it "should not require password after saving" do
      subject.require_password!
      subject.password = "newpass"
      subject.password_confirmation = "newpass"
      subject.save.should be_true
      subject.require_password?.should be_false
    end

    it "should require password confirmation when it has changed" do
      subject.password = "newpass"
      subject.should_not be_valid
      subject.errors[:password_confirmation].should_not be_empty
    end

    it "should require password when it has changed to blank" do
      subject.password = nil
      subject.should_not be_valid
      subject.errors[:password].should_not be_empty
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
      model.authenticate("johndoe", "invalid").should be_nil
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
