module RedirectableHandler
  extend ActiveSupport::Concern
  
  def redirect_unless(url, status: :see_other, with_flash: {message: nil, type: nil})
    if block_given?
      unless yield
        flash[with_flash[:type]] = with_flash[:message] if with_flash[:message] && with_flash[:type]
        # store_requested_url if url.match?(login_url)
        redirect_to(url, status: status) and return
      end
    end
  end
end