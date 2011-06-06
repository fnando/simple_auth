require "spec_helper"

describe SimpleAuth::Session do
  before do
    User.delete_all

    @user = User.create!(
      :login => "johndoe",
      :email => "john@doe.com",
      :password => "test",
      :password_confirmation => "test"
    )

    @session = Hash.new
    @controller = ActionController::Base.new
    @controller.stub :session => @session, :reset_session => nil

    SimpleAuth::Config.controller = @controller
    @user_session = SimpleAuth::Session.new(:credential => "johndoe", :password => "test")
  end

  it "should not raise when trying to find a session without activating controller" do
    SimpleAuth::Config.controller = nil

    expect {
      SimpleAuth::Session.find.should be_nil
    }.to_not raise_error
  end

  it "should return session key" do
    SimpleAuth::Session.session_key == :user_id
  end

  it "should return record id" do
    @session[:user_id] = 42
    SimpleAuth::Session.record_id == 42
  end

  context "with valid credentials" do
    before do
      @user_session.save!
    end

    it "should return existing session" do
      @user_session = SimpleAuth::Session.find
      @user_session.should be_valid
      @user_session.record.should == @user
    end

    it "should not be new record" do
      @user_session.should_not be_new_record
    end

    it "should be invalid when record is not authorized" do
      @user_session.record.stub :authorized? => false
      @user_session.should_not be_valid
    end

    it "should be valid when record is authorized" do
      @user_session.record.stub :authorized? => true
      @user_session.should be_valid
    end

    it "should find record" do
      @user_session.record.should == @user
    end

    it "should be saved" do
      @user_session.save.should be_true
    end

    it "should reset session before saving" do
      @session[:session_id] = "xWA1"
      @user_session.save
      @session.should_not have_key(:session_id)
    end

    it "should automatically save session when calling create!" do
      @user_session = SimpleAuth::Session.create!(:credential => "johndoe", :password => "test")
      @user_session.should be_valid
      @user_session.record.should == @user
      @session[:user_id].should == @user.id
    end

    it "should destroy session" do
      @user_session.destroy.should be_true
      @user_session.record.should be_nil
      @session.should_not have_key(:user)
    end

    it "should initialize record session" do
      @user_session.save
      @session[:user_id].should == @user.id
    end
  end

  context "with invalid credentials" do
    before do
      @user_session.credential = "invalid"
      @user_session.save
    end

    it "should unset previous record id when is not valid" do
      @session[:user_id] = 1
      @user_session.should_not be_valid
      @session.should_not have_key(:user)
    end

    it "should unset previous record id when is not saved" do
      @session[:user_id] = 1
      @user_session.save.should be_false
      @session.should_not have_key(:user)
    end

    it "should be new record" do
      SimpleAuth::Session.new.should be_new_record
      @user_session.should be_new_record
    end

    it "should have error message" do
      @user_session.errors.full_messages[0].should == "Invalid username or password"
    end

    it "should not return error messages for attributes" do
      @user_session.errors.on(:credential).should be_nil
      @user_session.errors.on(:password).should be_nil
    end

    it "should return empty array when trying to get errors by using hash syntax" do
      @user_session.errors[:credential].should be_empty
      @user_session.errors[:password].should be_empty
    end

    it "should have errors" do
      @user_session.errors.should_not be_empty
    end

    it "should not find existing session" do
      SimpleAuth::Session.find.should be_nil
    end

    it "should not find record" do
      @user_session.record.should be_nil
    end

    it "should not be a valid session" do
      @user_session.should_not be_valid
    end

    it "should unset record store from session" do
      @session.should_not have_key(:user)
    end

    it "should not be saved" do
      @user_session.save.should be_false
    end

    it "should raise error with save!" do
      expect { @user_session.save! }.to raise_error(SimpleAuth::NotAuthorized)
    end

    it "should raise error with create!" do
      expect { SimpleAuth::Session.create!({}) }.to raise_error(SimpleAuth::NotAuthorized)
    end
  end

  context "when destroying session" do
    before do
      @user_session.save!
    end

    it "should keep return to url" do
      @session[:return_to] = "/some/path"
      @user_session.destroy
      @session[:return_to].should == "/some/path"
    end

    it "should remove record session" do
      @user_session.destroy
      @session.should_not have_key(:user_id)
    end

    it "should keep keys composed by user_*" do
      SimpleAuth::Config.wipeout_session = false

      @session[:user_friends_count] = 42
      @user_session.destroy

      @session[:user_friends_count].should == 42
    end

    it "should wipe out keys composed by user_*" do
      SimpleAuth::Config.wipeout_session = true

      @session[:user_friends_count] = 100
      @session[:user_preferred_number] = 42

      @user_session.destroy

      @session.should_not have_key(:user_friends_count)
      @session.should_not have_key(:user_preferred_number)
    end

    it "should unset current_user instance variable" do
      @user_session.destroy

      SimpleAuth::Config.controller.send(:current_user).should be_nil
      SimpleAuth::Config.controller.instance_variable_get("@current_user").should be_nil
      SimpleAuth::Config.controller.instance_variable_get("@current_session").should be_nil
    end
  end
end
