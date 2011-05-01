require "spec_helper"

describe "Initializer" do
  it "runs smoothly" do
    expect {
      load File.dirname(__FILE__) + "/../../templates/initializer.rb"
    }.to_not raise_error
  end
end
