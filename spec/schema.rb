ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :email, :login, :password_hash, :password_salt, :username
  end
end
