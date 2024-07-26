source "https://rubygems.org"

ruby "3.3.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
# gem "rails", "~> 7.1.3", ">= 7.1.3.4"
gem "rails", "7.1.3.4"

# esto lo añade el tutorial de la sample app
gem "sassc-rails", "2.1.2" 

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails", "3.5.1"

# Use sqlite3 as the database for Active Record
# gem "sqlite3", "~> 1.4" # la sample app incluye esta gema solo en el grupo :development y :test

# Use the Puma web server [https://github.com/puma/puma]
# gem "puma", ">= 5.0"
gem "puma", "6.4.2"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "2.0.1"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "2.0.6"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "1.3.3"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", "2.12.0"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "1.18.3", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "sqlite3", "1.7.3"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "1.9.2", platforms: %i[ mri windows ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "4.2.1"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "3.40.0"
  gem "selenium-webdriver", "4.23.0"
  # gem "webdrivers", "5.3.1"
  gem "rails-controller-testing", "1.0.5"
  gem "minitest", "5.24.1"
  gem "minitest-reporters", "1.7.1"
  gem "guard", "2.18.1"
  gem "guard-minitest", "2.4.6"
end

group :production do
  gem "pg", "1.5.6"
end
