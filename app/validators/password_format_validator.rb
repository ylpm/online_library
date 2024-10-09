class PasswordFormatValidator < ActiveModel::EachValidator
  
  VALID_PASSWORD_REGEXP = /\A(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[\W]).{8,}$\z/.freeze
    
  def validate_each(record, attribute, value)
    unless VALID_PASSWORD_REGEXP.match?(value)
      record.errors.add(attribute, options[:message] || "must have uppercase and lowercase letters, numbers, and special characters")
    end
  end
end