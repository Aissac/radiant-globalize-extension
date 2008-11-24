module GlobalizeTags
  include Radiant::Taggable
  
  class TagError < StandardError; end
  
  def self.included(base)
    base.class_eval do
      alias_method_chain 'tag:link', :globalize
      alias_method_chain :relative_url_for, :globalize
    end
  end
  
  def relative_url_for_with_globalize(*args)
    '/' + Locale.active.code + relative_url_for_without_globalize(*args)
  end
  
  tag 'link_with_globalize' do |tag|
    locale = tag.attr.delete('locale')
    if locale
      Locale.switch_locale(locale) do
        send('tag:link_without_globalize', tag)
      end
    else
      send('tag:link_without_globalize', tag)
    end
  end
  
  tag 'locales' do |tag|
    hash = tag.locals.locale = {}
    tag.expand
    raise TagError.new("`locales' tag must include a `normal' tag") unless hash.has_key? :normal
    
    result = []
    codes = tag.attr['codes'].split('|').each do |code|
      hash[:code] = code
      if Locale.active.code == code
        result << (hash[:active] || hash[:normal]).call
      else
        Locale.switch_locale(code) do
          result << hash[:normal].call
        end
      end
    end
    between = hash.has_key?(:between) ? hash[:between].call : ' '
    result.reject { |i| i.blank? }.join(between)
  end
  
  [:normal, :active].each do |symbol|
    tag "locales:#{symbol}" do |tag|
      hash = tag.locals.locale
      hash[symbol] = tag.block
    end
  end
  
  tag 'locales:code' do |tag|
    hash = tag.locals.locale
    hash[:code]
  end
  
  desc "Locale set temporar"
  tag 'with_locale' do |tag|
    code = tag.attr['code']
    raise TagError.new("`code' must be set") if code.blank?
    result = ''
    Locale.switch_locale(code) do
      if defined?(PageAttachment)
        PageAttachment.send(:with_exclusive_scope, :find => {:conditions => {:locale => Locale.active.code}}) do
          result << tag.expand
        end
      else
        result << tag.expand
      end
    end
    result
  end
  
  desc "Prints out the current locale."
  tag 'locale' do |tag|
    Locale.active.code
  end
  
  desc "Only expands if the page title has a translation for the current locale."
  tag 'if_translation_title' do |tag|
    page = tag.locals.page
    tag.expand unless page.send(Page.localized_facet(:title)).blank?
  end
  
  desc "Only expands if the page title does not have a translation for the current locale."
  tag 'unless_translation_title' do |tag|
    page = tag.locals.page
    tag.expand if page.send(Page.localized_facet(:title)).blank?
  end
  
  desc %{
    Only expands if specified part has translated content in the current locale.
    Usage:
        <code><pre><r:if_translation_content [part="body"]>...</r:if_translation_content></pre></code>
  }
  tag 'if_translation_content' do |tag|
    name = tag.attr['part'] || 'body'
    raise TagError.new("`part' must be set") if name.blank?
    part = tag.locals.page.part(name)
    tag.expand if part && !part.send(PagePart.localized_facet(:content)).blank?
  end
  
  desc "Only expands if specified part does not have translated content in the current locale."
  tag 'unless_translation_content' do |tag|
    name = tag.attr['part'] || 'body'
    raise TagError.new("`part' must be set") if name.blank?
    part = tag.locals.page.part(name)
    tag.expand if part.nil? || part.send(PagePart.localized_facet(:content)).blank?
  end
end