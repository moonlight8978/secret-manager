class Command < Thor
  def self.exit_on_failure?
    true
  end

  desc "keygen", "Generate a symmetric encryption key for AES"
  method_option :secret, :aliases => "-s", :desc => "Secret in plain-text"
  def keygen
    secret = options.fetch(:secret) { SecureRandom.uuid }
    key = KeyManager.generate_key(secret)
    pp key
  end

  desc "encrypt", "Encrypt files"
  method_option :debug, :aliases => "-d", :desc => "Debug enabled"
  method_option :key, :aliases => "-k", :desc => "Encrypt key (Symmetric)"
  def encrypt
    kms = KeyManager.new(key_from_config)

    home_dir = File.expand_path("~", APP_ROOT)
    files = Settings.cipher.map do |matcher|
      if matcher.is_a?(String)
        File.expand_path(matcher, APP_ROOT)
      elsif matcher.patterns
        ignore_patterns = matcher.patterns.select { |pattern| pattern.start_with?("!") }
          .map { |pattern| File.expand_path(pattern.slice(1..), APP_ROOT) }

        include_patterns = matcher.patterns.select { |pattern| !pattern.start_with?("!") }
          .map { |pattern| File.expand_path(pattern, APP_ROOT) }

        Dir.glob(include_patterns).select do |file|
          ignore = ignore_patterns.any? { |pattern| File.fnmatch(pattern, file) }
          puts "Encrypt ignore: #{file}" if ignore
          !ignore
        end
      end
    end.flatten
      .map do |glob|
        glob.gsub(APP_ROOT, ".").gsub(home_dir, "~")
      end
      .each do |filename|
        kms.encrypt(filename, kms.iv)
      end
  end

  desc "decrypt", "Decrypt files"
  method_option :debug, :aliases => "-d", :desc => "Debug enabled"
  method_option :key, :aliases => "-k", :desc => "Decrypt key (Symmetric)"
  def decrypt
    kms = KeyManager.new(key_from_config)

    Dir.glob(['encrypted/*.enc']).each do |file|
      kms.decrypt(File.basename(file, ".*"), debug: debug_from_config)
    end
  end

  desc "backup", "Backup files"
  method_option :debug, :aliases => "-d", :desc => "Debug enabled"
  def backup
    backup_service = BackupService.new

    home_dir = File.expand_path("~", APP_ROOT)
    files = Settings.backup.map do |matcher|
      if matcher.is_a?(String)
        File.expand_path(matcher, APP_ROOT)
      elsif matcher.patterns
        ignore_patterns = matcher.patterns.select { |pattern| pattern.start_with?("!") }
          .map { |pattern| File.expand_path(pattern.slice(1..), APP_ROOT) }

        include_patterns = matcher.patterns.select { |pattern| !pattern.start_with?("!") }
          .map { |pattern| File.expand_path(pattern, APP_ROOT) }

        Dir.glob(include_patterns).select do |file|
          ignore = ignore_patterns.any? { |pattern| File.fnmatch(pattern, file) }
          puts "Backup ignore: #{file}" if ignore
          !ignore
        end
      end
    end.flatten
      .map do |glob|
        glob.gsub(APP_ROOT, ".").gsub(home_dir, "~")
      end
      .each do |filename|
        backup_service.backup(filename)
      end
  end

  desc "restore", "Restore files"
  method_option :debug, :aliases => "-d", :desc => "Debug enabled"
  def restore

  end

  private

  def key_from_config
    options.fetch(:key) { ENV["KEY"] }.tap do |key|
      pp key unless debug_from_config
      raise ArgumentError(:key, "Missing KEY") if key.blank?
    end
  end

  def debug_from_config
    options.fetch(:debug) { false }
  end
end
