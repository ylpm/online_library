class ProfanityValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    record.errors.add(attribute, options[:message] || "is forbbiden") if Profanity.check(value.downcase)
  end
end