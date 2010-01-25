require File.dirname(__FILE__) + "/../spec_helper"

describe SimpleAuth::Session do
  before do
    @user = User.create!(
      :login => "johndoe",
      :email => "john@doe.com",
      :password => "test",
      :password_confirmation => "test"
    )

    @session = Hash.new
    @controller = SampleController.new
    @controller.session = @session

    SimpleAuth::Config.controller = @controller
    @user_session = SimpleAuth::Session.new(:credential => "johndoe", :password => "test")
  end

  context "valid credentials" do
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

    it "should find record" do
      @user_session.record.should == @user
    end

    it "should be a valid session" do
      @user_session.should be_valid
    end

    it "should set record_id on session" do
      @session[:record_id].should == @user.id
    end

    it "should be saved" do
      @user_session.save.should be_true
    end

    it "should automatically save session when calling create!" do
      @user_session = SimpleAuth::Session.create!(:credential => "johndoe", :password => "test")
      @user_session.should be_valid
      @user_session.record.should == @user
      @session[:record_id].should == @user.id
    end

    it "should reset session" do
      SimpleAuth::Config.reset_session = true
      SimpleAuth::Config.controller.should_receive(:reset_session)
      @user_session.save
    end

    it "should destroy session" do
      @user_session.destroy.should be_true
      @user_session.record.should be_nil
      @session[:record_id].should be_nil
    end
  end

  context "invalid credentials" do
    before do
      @user_session.credential = "invalid"
      @user_session.save
    end

    it "should unset previous record id when is not valid" do
      @session[:record_id] = 1
      @user_session.should_not be_valid
      @session[:record_id].should be_nil
    end

    it "should unset previous record id when is not saved" do
      @session[:record_id] = 1
      @user_session.save.should be_false
      @session[:record_id].should be_nil
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

    it "should unset record_id from session" do
      @session[:record_id].should be_nil
    end

    it "should not be saved" do
      @user_session.save.should be_false
    end

    it "should raise error with save!" do
      doing { @user_session.save! }.should raise_error(SimpleAuth::NotAuthorized)
    end

    it "should raise error with create!" do
      doing { SimpleAuth::Session.create!({}) }.should raise_error(SimpleAuth::NotAuthorized)
    end
  end

  context "destroying valid session" do
    before do
      @user_session.save!
      @user_session.destroy
    end

    it "should unset record_id from session" do
      @session[:record_id].should be_nil
    end

    it "should unset current_user instance variable" do
      SimpleAuth::Config.controller.send(:current_user).should be_nil
      SimpleAuth::Config.controller.instance_variable_get("@current_user").should be_nil
      SimpleAuth::Config.controller.instance_variable_get("@current_session").should be_nil
    end
  end
end
