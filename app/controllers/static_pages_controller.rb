class StaticPagesController < ApplicationController
  before_action :cancel_friendly_forwarding
  
  def home
  end

  def help
  end
  
  def about
  end
end
