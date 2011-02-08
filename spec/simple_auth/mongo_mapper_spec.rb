require "spec_helper"

describe SimpleAuth::Orm::MongoMapper do
  let(:model) { Account }
  let(:model_name) { :account }
  subject { model.new }
  before { model.delete_all }

  it_should_behave_like "orm"
end
