module ApplicationHelper
  
  def base_title = "Online Library"
  
  def full_title(page_title = '') = page_title.blank? ? base_title : "#{page_title} | #{base_title}"
    
  def errors_from(models: [])
    errors = {}
    models.each do |model|
      model_errors = {}
      if model.errors.any?
        model.errors.messages.each do |field, error_messages|
           model_errors[field] = error_messages.first
        end 
        errors[model.class.to_s.downcase.to_sym] = model_errors if model_errors.any?
      end
    end
    errors
  end
        
end
