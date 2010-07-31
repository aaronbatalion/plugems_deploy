require 'rubygems'   
require 'plugems_deploy/dependency_handler'
require 'plugems_deploy/manifest'

desc 'Updates local gem repository from remote gem servers based on the content of manifest.yml'
task :plugem_update do 

  self.class.send(:include, PlugemsDeployInstall)

  validate_local_cache_permissions!
            
  manifest = PlugemsDeploy::Manifest.new
  
  manifest.dependencies.each do |name, version|
    puts "Updating #{ name } (#{ version })"
    set :plugem_name, name
    set :plugem_version, version
    plugem_install
  end
  
end


