require File.dirname(__FILE__) + "/../spec_helper"

describe SimpleAuth::ActiveRecord do
  context "new record" do
    subject { User.new }

    before do
      subject.should_not be_valid
    end

    it "should require password" do
      [subject.errors[:password]].flatten.should have(1).item
    end

    it "should require password to be at least 4-chars long" do
      subject.password = "123"
      subject.should_not be_valid
      [subject.errors[:password]].flatten.should have(1).item
    end

    it "should require password confirmation not to be empty" do
      subject.password_confirmation = ""
      [subject.errors[:password_confirmation]].flatten.should have(1).item
    end

    it "should require password confirmation not to be nil" do
      subject.password_confirmation = nil
      [subject.errors[:password_confirmation]].flatten.should have(1).item
    end

    it "should unset password after saving" do
      subject = User.new(:password => "test", :password_confirmation => "test")
      subject.save
      subject.password.should be_nil
      subject.password_confirmation.should be_nil
    end

    it "should mark password as changed" do
      subject = User.new(:password => "test")
      subject.password_changed?.should be_true
    end

    it "should not mark password as changed" do
      subject = User.new
      subject.password_changed?.should be_false
    end

    it "should mark password as unchanged after saving" do
      subject = User.new(:password => "test", :password_confirmation => "test")
      subject.save
      subject.password_changed?.should be_false
    end
  end

  context "existing record" do
    subject {
      User.new(
        :email => "john@doe.com",
        :login => "johndoe",
        :password => "test",
        :password_confirmation => "test",
        :username => "john"
      )
    }

    before do
      subject.save!
    end

    it "should not require password when it hasn't changed" do
      subject.login = "john"
      subject.should be_valid
    end

    it "should require password confirmation when it has changed" do
      subject.password = "newpass"
      subject.should_not be_valid
      [subject.errors[:password_confirmation]].flatten.should have(1).item
    end

    it "should require password when it has changed to blank" do
      subject.password = nil
      subject.should_not be_valid
      [subject.errors[:password]].flatten.should have(1).item
    end

    it "should authenticate using email" do
      User.authenticate("john@doe.com", "test").should == subject
    end

    it "should authenticate using login" do
      User.authenticate("johndoe", "test").should == subject
    end

    it "should authenticate using custom attribute" do
      SimpleAuth::Config.credentials = [:username]
      User.authenticate("john", "test").should == subject
    end

    it "should not authenticate using invalid credential" do
      User.authenticate("invalid", "test").should be_nil
    end

    it "should not authenticate using wrong password" do
      User.authenticate("johndoe", "invalid").should be_nil
    end
  end
end
