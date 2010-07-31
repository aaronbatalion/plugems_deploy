require 'rake'
require 'rake/gempackagetask'
require 'plugems_deploy/manifest'
require 'fileutils'

module PlugemsDeployBuild

  include FileUtils

  def gem_version
    version_specified? ? plugem_version : get_gem_version
  end
  
  def version_specified?
    ! (plugem_version.empty? || (plugem_version == '> 0.0'))
  end
  
  def get_gem_version
    micro = gem_micro_revision || @manifest.version[2] || 0
    ver = (@manifest.version + [0,0])[0..1].join('.')
    "#{ ver }.#{ micro }"
  end
  
  def gem_homepage
    nil
  end
  
  def gem_author
    @manifest.author
  end
  
  def gem_requirements
    [ 'none' ]
  end
  
  def gem_require_path
    'lib'
  end
    
  def add_gem_dependencies(s)
    @manifest.dependencies.each do |name,version|
      s.add_dependency(name, version || '>= 0.0.0') unless package_ignored_gems.include?(name)
    end
  end
  
  def gem_files
    Dir["**/*"].reject { |f| f == 'test' }
  end
  
  def gem_test_files
    Dir['test/**/*_test.rb']
  end
  
  def add_auto_require(s)
    s.autorequire = plugem_name if File.exist?("lib/#{plugem_name}.rb")
  end
  
  def plugem_name
    @manifest.name
  end

  def gem_spec

    @manifest = PlugemsDeploy::Manifest.new
    
    spec = Gem::Specification.new do |s|
    
      s.platform = Gem::Platform::RUBY
      s.summary = @manifest.description
      s.name = plugem_name
      s.version = gem_version
      s.homepage = gem_homepage if gem_homepage

      s.author = gem_author
      s.requirements = gem_requirements
      s.require_path = gem_require_path
                    
      s.files = gem_files
      s.test_files = gem_test_files
      s.description = @manifest.description

      s.executables = @manifest.executables
    
      add_auto_require(s)
    
      add_gem_dependencies(s)
    
      finalize_gem_spec(s)
      
    end
    
  end
  
  def finalize_gem_spec(s)
    # Use this method to add/overwrite any spec attributes
  end
  
end

# Allows to have some gem depdencies used at the run time only but not at the packaging time
set :package_ignored_gems, []

# Allows to define the micro revision from the external recipe file
set :gem_micro_revision, nil

desc 'Builds a gem package locally'
task :plugem_build do

  self.class.send(:include, PlugemsDeployBuild)

  rm_rf('pkg')

  Rake::GemPackageTask.new(gem_spec) do |pkg|
    additional_gem_packaging_tasks(pkg) if self.class.method_defined?(:additional_gem_packaging_tasks)
  end
  
  Rake::Task['package'].invoke 
    
end
