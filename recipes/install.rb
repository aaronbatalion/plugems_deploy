require 'rubygems'   
require 'plugems_deploy/gem_service'
require 'plugems_deploy/dependency_handler'
require 'plugems_deploy/manifest'
require 'rubygems/remote_installer'

module PlugemsDeployInstall

  def validate_local_cache_permissions!
    if ! (force_sudo_for_gem_installs || File.writable?(Gem.dir))
      fail "You don't have write permissions to #{ Gem.dir }. Consider using sudo."
    end
  end
  
  def local_gems
    @local_gems ||= PlugemsDeploy::GemService.new
  end

  def not_installed?(gem)
    local_gems.find_gem(gem[:name], gem[:version]).nil?
  end

  def remote_gems
    PlugemsDeploy::DependencyHandler.new(remote_sources).dependencies(plugem_name, plugem_version, plugem_deps_only)  
  end

  def remote_sources
    PlugemsDeploy::GemService.new(local_gem_servers)   
  end

  def install_gem(gem)
    cmd = "#{sudo_if_needed(gem)}gem install #{gem[:name]} --version #{gem[:version]} --remote --ignore-dependencies --force --source #{gem[:download_source]}"
    system cmd
  rescue Exception => ex
    fail "Error: installing gem #{gem[:name]} -- '#{ex}'\nTry running\n\n#{cmd}\n\n"
  end

  def sudo_if_needed(gem)
    return "" unless force_sudo_for_gem_installs
    case RUBY_PLATFORM
      when /win32/i
        "cmd /C"
      when /cygwin/i
        ""
      else
        "sudo "
    end
  end

end

desc 'Installs gems to a local gem repository from remote gem servers'
task :plugem_install do 
    
  self.class.send(:include, PlugemsDeployInstall)

  validate_local_cache_permissions!
  
  remote_gems.each do |gem|
    if not_installed?(gem)
      puts "Installing [ #{ gem[:name] }, #{ gem[:version] } ]"
      install_gem(gem)
    end
  end
  
end
