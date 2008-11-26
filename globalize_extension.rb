# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class GlobalizeExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/globalize"
  
  raise "You must define GLOBALIZE_BASE_LANGUAGE in your environment.rb" unless defined?(GLOBALIZE_BASE_LANGUAGE)
  raise "You must define GLOBALIZE_LANGUAGES in your environment.rb" unless defined?(GLOBALIZE_LANGUAGES)
  
  define_routes do |map|
    map.connect '/:locale/*url', :controller => 'site', :action => 'show_page',
      :locale => Regexp.compile((GLOBALIZE_LANGUAGES.dup.push(GLOBALIZE_BASE_LANGUAGE)).join('|'))
  end
  
  GLOBALIZABLE_CONTENT = {
    Page     => [:title, :slug, :breadcrumb, :description, :keywords],
    PagePart => [:content],
    Layout   => [:content],
    Snippet  => [:content]
  }
  
  def self.globalize_scoped_models
    defined?(GLOBALIZE_SCOPED_MODELS) && GLOBALIZE_SCOPED_MODELS || []
  end
  
  def self.locales
    @@locales ||= [GLOBALIZE_BASE_LANGUAGE, *GLOBALIZE_LANGUAGES].map(&:to_s)
  end
  
  def activate
    admin.page.edit.add :form, 'admin/shared/change_locale', :before => 'edit_page_parts'
    admin.snippet.edit.add :form, 'admin/shared/change_locale', :before => 'edit_content'
    admin.layout.edit.add :form, 'admin/shared/change_locale', :before => 'edit_content'
    
    ApplicationController.send(:include, ApplicationControllerExtensions)
    Admin::PageController.send(:include, PageControllerExtensions)
    ArchivePage.send(:include, ArchivePageExtensions)
    ResponseCache.send(:include, ResponseCacheExtensions)
    Page.class_eval {
      include GlobalizeTags
    }
    
    Globalize::Locale.set_base_language(GLOBALIZE_BASE_LANGUAGE)
    
    GLOBALIZABLE_CONTENT.each do |model, columns|
      model.keep_translations_in_model = true
      model.send(:translates, *columns.dup.push(:base_as_default => true))
    end
  end
  
  def deactivate
  end
  
end