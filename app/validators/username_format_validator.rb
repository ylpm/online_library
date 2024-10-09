class UsernameFormatValidator < ActiveModel::EachValidator
  
  VALID_USERNAME_REGEXP = /\A[a-z]([\-\_\.]?[a-z\d]+)+\Z/i.freeze
  
  def validate_each(record, attribute, value)
    unless VALID_USERNAME_REGEXP.match?(value)
      record.errors.add(attribute, options[:message] || "starts with a letter and allows hyphens, dots and numbers after, p.e. john.doe")
    end
  end
end