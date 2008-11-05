module ResponseCacheExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval <<-END
      alias_method_chain :page_cache_path, :locale
    END
  end

  module InstanceMethods
    def page_cache_path_with_locale(path)
      page_cache_path_without_locale(Locale.active.code+'/'+path)
    end
  end
end