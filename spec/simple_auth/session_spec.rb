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
    @controller.stub :session => @session

    SimpleAuth::Config.controller = @controller
    @user_session = SimpleAuth::Session.new(:credential => "johndoe", :password => "test")
  end

  it "should not raise when trying to find a session without activating controller" do
    SimpleAuth::Config.controller = nil

    expect {
      SimpleAuth::Session.find.should be_nil
    }.to_not raise_error
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

  context "with invalid credentials" do
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

    it "should unset record_id from session" do
      @session[:record_id].should be_nil
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
