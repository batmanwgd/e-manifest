class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  after_action :extend_session

  private

  def extend_session
    if user_session
      user_session.touch
    end
  end

  def current_user
    @current_user ||= find_current_user
  end

  def authenticate_user!
    unless authenticated?
      flash[:error] = 'You must be logged in to access this page.'
      session[:back] = request.original_url
      redirect_to login_path(back: session[:back])
    end
  end

  def find_current_user
    if user_session
      user_session.user
    end
  end

  def user_session
    if session[:user_session_id]
      UserSession.new(session[:user_session_id])
    elsif params[:token] && params[:token].is_a?(String)
      UserSession.new(params[:token])
    end
  end

  def authenticated?
    current_user.present?
  end
end
