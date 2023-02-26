class BackupService
  def backup(filename)
    from_path = File.expand_path(filename, APP_ROOT)
    filename64 = Base64.strict_encode64(filename)
    dest_path = File.expand_path("backup/#{filename64}.bak", APP_ROOT)
    meta_path = dest_path.ext(".yml")
    meta =
      if File.exists?(meta_path)
        YAML.load(File.read(meta_path))
      else
        {
          from: filename
        }.tap do |m|
          File.open(meta_path, "w") do |meta_f|
            meta_f << m.to_yaml
          end
        end
      end

    FileUtils.cp(from_path, dest_path)

    puts "Backup finished: #{filename}"
  end
end
