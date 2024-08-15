module ApplicationHelper
  
  def base_title = "Online Library"
  
  def full_title(page_title = '') = page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  
  def logged_in? = false
    
  def errors_from(models: [])
    errors = {}
    models.each do |model| 
      model_error = {}
      model.errors.messages.each do |field, error_messages|
         model_error[field] = error_messages.first
      end 
      errors[model.class.to_s.downcase.to_sym] = model_error
    end
    errors
  end
        
end
