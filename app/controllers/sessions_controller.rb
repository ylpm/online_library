class SessionsController < ApplicationController  
  def create
    @user = User.find_by_login(params[:session][:login])
    respond_to do |format|
      if @user&.authenticate(params[:session][:password])
        # login
        format.html do
          flash[:success] = "You have logged in successfully!"
          redirect_to(@user, status: :see_other) and return
        end
      else
        @login_error = "ooops! no match"
        format.turbo_stream
        format.html {render :new, status: :unprocessable_entity}
      end
    end
  end
  
end
