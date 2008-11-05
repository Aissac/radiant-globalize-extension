namespace :radiant do
  namespace :extensions do
    namespace :globalize do
      
      desc "Runs the migration of the Globalize extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        
        GlobalizeExtension.migrator.set_schema_version(0)
        
        if ENV["VERSION"]
          GlobalizeExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          GlobalizeExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Globalize to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[GlobalizeExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(GlobalizeExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
