require "spec_helper"

describe SimpleAuth::ActiveRecord do
  let(:model) { User }
  let(:model_name) { :user }
  subject { model.new }

  before do
    SimpleAuth::Config.model = model_name
  end

  context "configuration" do
    it "sets credentials" do
      model.authentication do |config|
        config.credentials = ["uid"]
      end

      expect(SimpleAuth::Config.credentials).to eq(["uid"])
    end

    it "automatically sets model" do
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

    it "requires password", if: $rails_version >= "4.0" do
      expect(subject.errors[:password]).not_to be_empty
    end

    it "requires password", if: $rails_version < "4.0" do
      expect(subject.errors[:password_digest]).not_to be_empty
    end

    it "requires password to be at least 4-chars long" do
      subject.password = "123"
      expect(subject).not_to be_valid
      expect(subject.errors[:password]).not_to be_empty
    end

    it "requires password confirmation", if: $rails_version >= "4.0" do
      user = User.create(password: "test", password_confirmation: "invalid")
      expect(user.errors[:password_confirmation]).not_to be_empty
    end

    it "requires password confirmation", if: $rails_version < "4.0" do
      user = User.create(password: "test", password_confirmation: "invalid")
      expect(user.errors[:password]).not_to be_empty
    end
  end

  context "ignoring validations" do
    it "ignores validations", if: $rails_version >= "4.0" do
      person = Person.new
      expect(person).to be_valid
    end
  end

  context "existing record" do
    before do
      model.delete_all
      model.create!(
        :email => "john@doe.com",
        :login => "johndoe",
        :password => "test",
        :password_confirmation => "test",
        :username => "john"
      )
    end

    subject { model.first }

    it "requires password", if: $rails_version >= "4.0" do
      user = User.create(password: nil)
      expect(user.errors[:password]).not_to be_empty
    end

    it "requires password", if: $rails_version < "4.0" do
      user = User.create(password: nil)
      expect(user.errors[:password_digest]).not_to be_empty
    end

    it "authenticates using email" do
      expect(model.authenticate("john@doe.com", "test")).to eq(subject)
    end

    it "authenticates using login" do
      expect(model.authenticate("johndoe", "test")).to eq(subject)
    end

    it "authenticates using custom attribute" do
      SimpleAuth::Config.credentials = [:username]
      expect(model.authenticate("john", "test")).to eq(subject)
    end

    it "doesn't authenticate using invalid credential" do
      expect(model.authenticate("invalid", "test")).to be_nil
    end

    it "doesn't authenticate using wrong password" do
      expect(model.authenticate("johndoe", "invalid")).not_to be
    end

    it "returns nil when no user has been found" do
      expect(model.find_by_credential("invalid")).to be_nil
    end

    it "raises error when no user has been found" do
      expect {
        model.find_by_credential!("invalid")
      }.to raise_error(SimpleAuth::RecordNotFound)
    end

    it "skips password length validation when no password is set" do
      expect {
        subject.username = "jd"
        subject.save!
      }.not_to raise_error
    end

    it "enforces password length when password is set" do
      subject.password = "a"
      subject.valid?
      expect(subject.errors[:password]).to have(1).item
    end

    it "accepts valid password" do
      subject.password = "test"
      subject.valid?
      expect(subject.errors[:password]).to be_empty
    end

    it "returns user" do
      expect(model.find_by_credential(subject.email)).to eq(subject)
      expect(model.find_by_credential!(subject.email)).to eq(subject)
    end
  end
end
