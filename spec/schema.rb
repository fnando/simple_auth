ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :email, :login, :password_digest, :username
  end
end
