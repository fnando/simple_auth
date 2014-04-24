module SimpleAuth
  class Config
    # Generate the password hash. The specified block should expected
    # the plain password and the password hash as block parameters.
    cattr_accessor :crypter
    @@crypter = proc do |password, salt|
      Digest::SHA256.hexdigest [password, salt].join("--")
    end

    # Generate the password salt. The specified block should expect
    # the ActiveRecord instance as block parameter.
    cattr_accessor :salt
    @@salt = proc do |record|
      Digest::SHA256.hexdigest [Time.to_s, SecureRandom.hex(32)].join("--")
    end
  end
end
