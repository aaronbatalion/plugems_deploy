require 'yaml'

def cfg_dir
  File.join(File.dirname(__FILE__), '../config')
end

# Could be defined in projects
set :gem_servers, [ 'http://gems.rubyforge.org']

def local_gem_servers
  gem_servers
end

# Force sudo usage for installing missing gems instead of running 'sudo plugem'
set :force_sudo_for_gem_installs, false
