class EmailAddressFormatValidator < ActiveModel::EachValidator
  
  VALID_EMAIL_FORMAT = { PERMISSIVE: URI::MailTo::EMAIL_REGEXP, # ESTA ES DEMASIADO PERMISIVA, PERMITE EMAIL ADDRESSES TALES COMO: user@example
                             STRICT: /\A[a-z][a-z0-9\.\+\-\_]*@[a-z0-9]+[a-z\d\-]*(\.[a-z\d\-]+)*\.[a-z]{2,}\z/i
                       }.freeze
  
  def validate_each(record, attribute, value)
    strictness_option = options[:strictness].nil? ? nil : options[:strictness].upcase
    unless VALID_EMAIL_FORMAT[strictness_option || :STRICT].match?(value)
      record.errors.add(attribute, options[:message] || "requires a valid format: user@example.com")
    end
  end
end