class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_user_token

  private

  def set_user_token
    session[:user_token] ||= random_token
    Rails.logger.info session[:user_token]
  end

  def random_token
    rand(36**32).to_s(36)
  end

  def admin_only
    raise "AccessDenied" unless current_user.admin?
  end

end
