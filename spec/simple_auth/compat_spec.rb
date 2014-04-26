require "spec_helper"

describe SimpleAuth, "compatibility mode" do
  before do
    SimpleAuth::Config.model = :customer
    load "./lib/simple_auth/compat.rb"
    require "customer"
  end

  after :all do
    mod = SimpleAuth::ActiveRecord::InstanceMethods
    mod.send :remove_method, :password=
    mod.send :remove_method, :authenticate
  end

  it "finds user based on the hashing system" do
    password_salt = SecureRandom.hex
    password_hash = SimpleAuth::Config.crypter.call("test", password_salt)
    password_digest = BCrypt::Password.create(password_hash, cost: BCrypt::Engine::MIN_COST)

    ActiveRecord::Base.connection.execute <<-SQL
    INSERT INTO customers
      (email, login, password_digest, password_salt)
    VALUES
      ('john@example.org', 'johndoe', '#{password_digest}', '#{password_salt}')
    SQL

    expect(Customer.authenticate("johndoe", "test")).to be_a(Customer)
  end

  it "assigns password_digest" do
    customer = Customer.create(password: "test")
    expect(customer.password_digest).to be_present
  end

  it "sets password" do
    customer = Customer.create(password: "test", password_confirmation: "test")
    expect(customer.password).to eql("test")
  end

  it "sets password confirmation" do
    customer = Customer.create(password: "test", password_confirmation: "test")
    expect(customer.password_confirmation).to eql("test")
  end
end
