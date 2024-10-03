module ApplicationHelper
  
  def base_title = "PIXELART"
  
  def full_title(page_title = '') = page_title.blank? ? base_title : "#{page_title} | #{base_title}"
    
  def errors_from(models: [])
    errors = {}
    models.delete_if {|model| !model.respond_to?(:errors) || model.errors.empty?}
    models.each do |model|
      model_errors = {}
      # next unless model.errors.any?
      model.errors.messages.each do |field, error_messages|
          model_errors[field] = error_messages.first
      end 
      errors[model.class.to_s.downcase.to_sym] = model_errors if model_errors.any?
    end
    errors
  end
  
  def render_form_field_for(form = nil, attribute: nil)
    return if form.nil? || attribute.nil? || !block_given?
    
    if form.object.errors[attribute].empty?
      yield
    else
     tag.div class: "alert alert-danger" do
      yield
     end
    end
  end
  
  def render_error_for(form = nil, attribute: nil, css_class: nil)
    return if form.nil? || attribute.nil?
    
    unless form.object.errors.messages[attribute].first.blank?
    	tag.div class: "#{ css_class + " " unless css_class.nil? }field_with_errors text-small" do
    		form.object.errors.messages[attribute].first
    	end
    end
  end

end
