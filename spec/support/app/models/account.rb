class Account
  include MongoMapper::Document
  include SimpleAuth::Orm::MongoMapper

  authentication
end
