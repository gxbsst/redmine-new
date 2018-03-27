module RedmineCrm
  class AssetsManager
    def self.install_assets
      return unless Gem.loaded_specs['redmine_crm']
      source = File.join(Gem.loaded_specs['redmine_crm'].full_gem_path, 'vendor', 'assets')
      destination = File.join(Dir.pwd, 'public', 'plugin_assets', 'redmine_crm')
      return unless File.directory?(source)

      source_files = Dir[source + '/**/*']
      source_dirs = source_files.select { |d| File.directory?(d) }
      source_files -= source_dirs

      unless source_files.empty?
        base_target_dir = File.join(destination, File.dirname(source_files.first).gsub(source, ''))
        begin
          FileUtils.mkdir_p(base_target_dir)
        rescue Exception => e
          raise "Could not create directory #{base_target_dir}: " + e.message
        end
      end

      source_dirs.each do |dir|
        target_dir = File.join(destination, dir.gsub(source, ''))
        begin
          FileUtils.mkdir_p(target_dir)
        rescue Exception => e
          raise "Could not create directory #{target_dir}: " + e.message
        end
      end

      source_files.each do |file|
        begin
          target = File.join(destination, file.gsub(source, ''))
          unless File.exist?(target) && FileUtils.identical?(file, target)
            FileUtils.cp(file, target)
          end
        rescue Exception => e
          raise "Could not copy #{file} to #{target}: " + e.message
        end
      end
    end
  end
end
