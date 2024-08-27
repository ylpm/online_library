module RedirectableHandler
  extend ActiveSupport::Concern
  
  def redirect_unless(url = root_url, status: :see_other, with_flash: true , flash_message: "Access denied", flash_type: :danger)
    if block_given?
      unless yield
        flash[flash_type] = flash_message if with_flash
        store_requested_url if url.match?(login_url)
        redirect_to(url, status: status) and return
      end
    end
  end
end