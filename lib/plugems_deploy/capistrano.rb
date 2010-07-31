module Capistrano
  class Configuration
    alias :standard_cap_load :load
    def load(*args, &block)
      # we always call the original load
      standard_cap_load(*args, &block)
      
      # if this happens to be 'config.load "standard"' coming from the CLI, we hook in after
      # and load all our own recipes before system/dot preferences... if capistrano changes how
      # they load their "default" recipes, this will probably break
      if args == ["standard"]
        load_plugem_deploy_recipes(File.dirname(__FILE__) + '/../..')
        begin
          require 'plugems_deploy_ext'
          load_plugem_deploy_recipes(PLUGEMS_DEPLOY_EXT_DIR) # Overriding from extensions
        rescue Exception
          # No extension is loaded
        end
      end
    end
    
    def load_plugem_deploy_recipes(dir)
      Dir[File.join(dir, 'recipes', '*')].each { |f| standard_cap_load(f) }
    end
      
  end
end