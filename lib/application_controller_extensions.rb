module ApplicationControllerExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval <<-END
      before_filter :set_locale
    END
    
    if GlobalizeExtension.globalize_scoped_models.include?('PageAttachment')
      base.class_eval <<-END
        around_filter :globalization_scope
      END
    end
  end

  module InstanceMethods
    def set_locale
      @locale = params[:locale] || session[:locale] || GLOBALIZE_BASE_LANGUAGE
      
      session[:locale] = @locale
      Locale.set @locale
    end
    
    def globalization_scope
      globalization_scope = {
        :create => {:locale => Locale.active.code},
        :find => {:conditions => {:locale => Locale.active.code}}
      }
        
      PageAttachment.send(:with_scope, globalization_scope) do
        yield
      end
    end
  end
end
