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
    allow(@controller).to receive_messages :session => @session, :reset_session => nil

    SimpleAuth::Config.controller = @controller
    @user_session = SimpleAuth::Session.new(:credential => "johndoe", :password => "test")
  end

  it "doesn't raise when trying to find a session without activating controller" do
    SimpleAuth::Config.controller = nil

    expect {
      expect(SimpleAuth::Session.find).to be_nil
    }.to_not raise_error
  end

  it "returns session key" do
    SimpleAuth::Session.session_key == :user_id
  end

  it "returns record id" do
    @session[:user_id] = 42
    SimpleAuth::Session.record_id == 42
  end

  context "with valid credentials" do
    before do
      @user_session.save!
    end

    it "returns existing session" do
      @user_session = SimpleAuth::Session.find
      expect(@user_session).to be_valid
      expect(@user_session.record).to eq(@user)
    end

    it "doesn't be new record" do
      expect(@user_session).not_to be_new_record
    end

    it "is invalid when record is not authorized" do
      allow(@controller).to receive_messages :authorized? => false
      expect(@user_session).not_to be_valid
    end

    it "is valid when record is authorized" do
      allow(@user_session.record).to receive_messages :authorized? => true
      expect(@user_session).to be_valid
    end

    it "finds record" do
      expect(@user_session.record).to eq(@user)
    end

    it "is saved" do
      expect(@user_session.save).to be_truthy
    end

    it "resets session before saving" do
      @session[:session_id] = "xWA1"
      @user_session.save
      expect(@session).not_to have_key(:session_id)
    end

    it "automatically saves session when calling create!" do
      @user_session = SimpleAuth::Session.create!(:credential => "johndoe", :password => "test")
      expect(@user_session).to be_valid
      expect(@user_session.record).to eq(@user)
      expect(@session[:user_id]).to eq(@user.id)
    end

    it "destroys session" do
      expect(@user_session.destroy).to be_truthy
      expect(@user_session.record).to be_nil
      expect(@session).not_to have_key(:user)
    end

    it "initializes record session" do
      @user_session.save
      expect(@session[:user_id]).to eq(@user.id)
    end
  end

  context "with invalid credentials" do
    before do
      @user_session.credential = "invalid"
      @user_session.save
    end

    it "unsets previous record id when is not valid" do
      @session[:user_id] = 1
      expect(@user_session).not_to be_valid
      expect(@session).not_to have_key(:user)
    end

    it "unsets previous record id when is not saved" do
      @session[:user_id] = 1
      expect(@user_session.save).to be_falsey
      expect(@session).not_to have_key(:user)
    end

    it "is new record" do
      expect(SimpleAuth::Session.new).to be_new_record
      expect(@user_session).to be_new_record
    end

    it "has error message" do
      expect(@user_session.errors.full_messages[0]).to eq("Invalid username or password")
    end

    it "doesn't return error messages for attributes" do
      expect(@user_session.errors.on(:credential)).to be_nil
      expect(@user_session.errors.on(:password)).to be_nil
    end

    it "returns empty array when trying to get errors by using hash syntax" do
      expect(@user_session.errors[:credential]).to be_empty
      expect(@user_session.errors[:password]).to be_empty
    end

    it "has errors" do
      expect(@user_session.errors).not_to be_empty
    end

    it "doesn't find existing session" do
      expect(SimpleAuth::Session.find).to be_nil
    end

    it "doesn't find record" do
      expect(@user_session.record).to be_nil
    end

    it "doesn't be a valid session" do
      expect(@user_session).not_to be_valid
    end

    it "unsets record store from session" do
      expect(@session).not_to have_key(:user)
    end

    it "doesn't be saved" do
      expect(@user_session.save).to be_falsey
    end

    it "raises error with save!" do
      expect { @user_session.save! }.to raise_error(SimpleAuth::NotAuthorized)
    end

    it "raises error with create!" do
      expect { SimpleAuth::Session.create!({}) }.to raise_error(SimpleAuth::NotAuthorized)
    end
  end

  context "when destroying session" do
    before do
      @user_session.save!
    end

    it "keeps return to url" do
      @session[:return_to] = "/some/path"
      @user_session.destroy
      expect(@session[:return_to]).to eq("/some/path")
    end

    it "removes record session" do
      @user_session.destroy
      expect(@session).not_to have_key(:user_id)
    end

    it "keeps keys composed by user_*" do
      SimpleAuth::Config.wipeout_session = false

      @session[:user_friends_count] = 42
      @user_session.destroy

      expect(@session[:user_friends_count]).to eq(42)
    end

    it "erases keys composed by user_*" do
      SimpleAuth::Config.wipeout_session = true

      @session[:user_friends_count] = 100
      @session[:user_preferred_number] = 42

      @user_session.destroy

      expect(@session).not_to have_key(:user_friends_count)
      expect(@session).not_to have_key(:user_preferred_number)
    end

    it "unsets current_user instance variable" do
      @user_session.destroy

      expect(SimpleAuth::Config.controller.send(:current_user)).to be_nil
      expect(SimpleAuth::Config.controller.instance_variable_get("@current_user")).to be_nil
      expect(SimpleAuth::Config.controller.instance_variable_get("@current_session")).to be_nil
    end
  end
end
