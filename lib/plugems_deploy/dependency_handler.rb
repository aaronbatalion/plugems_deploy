module PlugemsDeploy
  class DependencyHandler
 
  require 'rubygems'
  require 'yaml'
  require 'plugems_deploy/gem_service'
  
  MAX_DEPENDENCY_DEPTH = 10000
  
  def initialize(source = local_cache)
    @gems = []
    @source = source
  end
     
  def dependencies(name, version, deps_only = false, show = false)
      
    gem = gem_data(query_gem_spec(name, version))

    mark_dependency(gem) unless deps_only == 'true'
    collect_dependencies(gem, show)
    
    compacted_collected_dependencies
  
  end
  
  def collect_dependencies(start_point, show)
        
    fail("Circular dependencies?\n#{ @gems.to_yaml }") if @gems.size > MAX_DEPENDENCY_DEPTH
        
    show_data("#{ start_point[:name] }: [ ", show)
    query_dependencies(start_point).each do |gem|
      mark_dependency(gem)
      show_data("  { #{ gem[:name] } => #{ gem[:version] } }", show)
      collect_dependencies(gem, show && (show + 4))      
    end
    show_data("]", show)
    
  end 

  
private

  def query_dependencies(gem)
    query_gem_spec(gem[:name], gem[:version]).dependencies.collect do |dependency|
      spec = query_gem_spec(dependency.name, dependency.version_requirements.to_s)
      gem_data(spec)
    end
  end

  def gem_data(spec)
    {
      :name => spec.name,
      :version => spec.version.to_s,
      :homepage => spec.homepage,
      :authors => spec.authors,
      :download_source => spec.download_source
    }
  end
  
  def mark_dependency(gem)
    @gems.unshift(gem) 
  end
  
  def marked?(gem)
    @gems.any? { |marked| marked[:name] == gem[:name] }
  end    

  def compacted_collected_dependencies
    @gems.inject([]) do |dependencies, gem|
      dependencies << gem unless dependencies.include?(gem)
      dependencies
    end
  end

  def query_gem_spec(name, version)
    @source.find_gem(name, version) || fail("No gem found for ['#{ name }', '#{ version }']")
  end

  def local_cache
    GemService.new
  end
  
  def show_data(data, show)
    puts  " " * show + data if show
  end
            
  end
end