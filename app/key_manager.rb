class KeyManager
  ALGORITHM = "AES-256-CBC"

  attr_accessor :secret, :aes

  def initialize(secret)
    self.secret = Base64.strict_decode64(secret)
    self.aes = OpenSSL::Cipher::Cipher.new(ALGORITHM)
  end

  def self.generate_key(secret)
    sha256 = Digest::SHA256.new
    sha256.update(secret)
    Base64.strict_encode64(sha256.digest)
  end

  def iv
    Base64.strict_encode64(aes.random_iv)
  end

  def encrypt(filename, iv)
    file_absolute_path = File.expand_path(filename, APP_ROOT)
    dest_filename = Base64.strict_encode64(filename)
    dest_path = File.expand_path("encrypted/#{Base64.strict_encode64(filename)}.enc", APP_ROOT)
    meta_path = dest_path.ext(".yml")

    meta =
      if File.exists?(meta_path)
        YAML.load(File.read(meta_path))
      else
        {
          from: filename,
          iv: iv
        }.tap do |m|
          File.open(meta_path, "w") do |meta_f|
            meta_f << m.to_yaml
          end
        end
      end


    aes.encrypt
    aes.key = secret
    aes.iv = Base64.strict_decode64(meta[:iv])

    File.open(dest_path, "w") do |cipher_f|
      File.foreach(file_absolute_path) do |line|
        cipher_text = aes.update(line)
        cipher_text << aes.final
        cipher_f.puts Base64.strict_encode64(cipher_text)
      end
    end

    puts "Encrypt finished: #{filename}"
  end

  def decrypt(filename64, **options)
    debug_enabled = options.fetch(:debug) { false }

    filename = Base64.strict_decode64(filename64)
    from_path = File.expand_path("encrypted/#{filename64}.enc", APP_ROOT)
    meta_path = from_path.ext(".yml")

    meta = YAML.load(File.read(meta_path))
    dest_path = debug_enabled ? File.expand_path("raw/#{filename64}", APP_ROOT) : File.expand_path(meta.fetch(:from), APP_ROOT)


    aes.decrypt
    aes.key = secret
    aes.iv = Base64.strict_decode64(meta[:iv])

    FileUtils.mkdir_p(File.dirname(dest_path))

    File.open(dest_path, "w") do |plain_f|
      File.foreach(from_path, chomp: true) do |line|
        plain = aes.update(Base64.strict_decode64(line))
        plain << aes.final
        plain_f.puts(plain)
      end
    end

    puts "Decrypt finished: #{filename}"
  end
end
