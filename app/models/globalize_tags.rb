module GlobalizeTags
  include Radiant::Taggable
  
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
  
  tag 'locale' do |tag|
    hash = tag.locals.locale = {}
    tag.expand
    raise TagError.new("`locale' tag must include a `normal' tag") unless hash.has_key? :normal
    
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
    tag "locale:#{symbol}" do |tag|
      hash = tag.locals.locale
      hash[symbol] = tag.block
    end
  end
  
  tag 'locale:code' do |tag|
    hash = tag.locals.locale
    hash[:code]
  end
end