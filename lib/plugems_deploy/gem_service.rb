module PlugemsDeploy
  class GemService

  require 'rubygems'
  require 'yaml'
  require 'rubygems/remote_installer'
    
  def initialize(sources = [ cache ])
    @sources = sources
    @indexes = { cache => Gem.cache }
  end
  
  def find_gem(name, version)
  
    @sources.each do |source|
      specs = index(source).search(/^#{ name }$/, version)
      return spec_with_source(specs.last, source) unless specs.empty?
    end
    
    nil
  
  end
  
private

  LATEST_RUBYGEMS = Gem::RubyGemsVersion.split('.').map{|v|v.to_i}.extend(Comparable) > [0,9,0]

  def cache
    'cache'
  end
  
  def index(source)
    @indexes[source] ||= source_index(source)
  end
  
  def spec_with_source(spec, source)
    spec.class.send(:attr_accessor, :download_source)
    spec.download_source = source
    spec
  end

  def source_index(source)
    LATEST_RUBYGEMS ? Gem::SourceIndex.new.update(source) : Gem::RemoteSourceFetcher.new(source, nil).source_index
  end

  end
end
