class UpdateGlobalizationColumns < ActiveRecord::Migration
  def self.globalizable_content
    GlobalizeExtension::GLOBALIZABLE_CONTENT
  end
  
  def self.up
    globalizable_content.each do |model, columns|
      columns.each do |column|
        GLOBALIZE_LANGUAGES.each do |lang|
          language_column_name = "#{column}_#{lang}"
          unless model.column_names.include?(language_column_name)
            base_column = model.columns.detect { |col| col.name == column.to_s } 
            add_column model.table_name, language_column_name, base_column.type, :limit => base_column.limit
          end
        end
      end
    end
    
    GlobalizeExtension.globalize_scoped_models.each do |model_name|
      model = model_name.constantize
      unless model.column_names.include?('locale')
        add_column model.table_name, 'locale', :string, :limit => 8
        add_index model.table_name, 'locale'
      end
    end
  end
end