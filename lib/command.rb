class Command < Thor
  def self.exit_on_failure?
    true
  end

  desc "keygen", "Generate a symmetric encryption key for AES"
  method_option :secret, :aliases => "-s", :desc => "Secret in plain-text"
  def keygen
    secret = options.fetch(:secret) { SecureRandom.uuid }
    key = KeyManager.generate_key(secret)
    puts key
  end

  desc "encrypt KEY", "Encrypt files"
  def encrypt(key)
    kms = KeyManager.new(key)
    kms.encrypt("~/.ssh/id_ed25519", kms.iv)
  end

  desc "decrypt KEY", "Decrypt files"
  method_option :debug, :aliases => "-d", :desc => "Debug enabled"
  def decrypt(key)
    kms = KeyManager.new(key)
    kms.decrypt("fi8uc3NoL2lkX2VkMjU1MTk=", debug: options.fetch(:debug) { false })
  end
end
