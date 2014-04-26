class Person < ActiveRecord::Base
  self.table_name = "users"
  authentication validations: false
end
