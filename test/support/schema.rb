ActiveRecord::Schema.define(version: 0) do
  create_table :users do |t|
    t.string :email, :password_digest, :username
    t.boolean :admin, default: false, null: false
  end
end
