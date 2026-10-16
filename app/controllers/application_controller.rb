class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_authentication

  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)
    return @current_user = nil unless session[:user_id]

    @current_user = User.active.find_by(id: session[:user_id])
    session.delete(:user_id) unless @current_user
    @current_user
  end

  def require_authentication
    return if current_user

    redirect_to login_path, alert: "Iniciá sesión para continuar."
  end

  def require_admin
    return if current_user&.admin?

    redirect_to root_path, alert: "No tenés permisos para acceder a esa sección."
  end
end
