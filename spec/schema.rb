ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :email, :login, :password_digest, :username
  end

  create_table :customers do |t|
    t.string :email, :login, :password_digest, :password_salt
  end
end
