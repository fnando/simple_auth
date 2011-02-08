require "spec_helper"

describe SimpleAuth::Orm::ActiveRecord do
  let(:model) { User }
  let(:model_name) { :user }
  subject { model.new }

  it_should_behave_like "orm"
end
