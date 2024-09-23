Rails.application.config.middleware.use ActionDispatch::Cookies do |config|
  config.httponly = true
  config.secure = Rails.env.production?
  config.same_site = :strict
end