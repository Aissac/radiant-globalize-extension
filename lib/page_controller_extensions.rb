module PageControllerExtensions
  def self.included(base)
    base.class_eval do
      def save
        parts = @page.parts
        parts_to_update = {}
        (params[:part]||{}).each {|k,v| parts_to_update[v[:name]] = v }
    
        parts_to_remove = []
        @page.parts.each do |part|
          if(attrs = parts_to_update.delete(part.name))
            # This is the only difference from Admin::PageController#save
            # Merging hashes makes attributes like "content_en" => nil remain and overwrite
            # values set by assigning "content" => "value" when Locale.active.code == 'de'
            # 
            # part.attributes = part.attributes.merge(attrs)
            part.attributes = attrs
          else
            parts_to_remove << part
          end
        end
        parts_to_update.values.each do |attrs|
          @page.parts.build(attrs)
        end
        if result = @page.save
          new_parts = @page.parts - parts_to_remove
          new_parts.each { |part| part.save }
          @page.parts = new_parts
        end
        result
      end
    end
  end
end