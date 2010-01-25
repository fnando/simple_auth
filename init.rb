require "simple_auth"

config.to_prepare do
  ApplicationController.helper SimpleAuthHelper
end
