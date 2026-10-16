class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to login_path, alert: "Demasiados intentos. Probá nuevamente en unos minutos." }

  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.active.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to root_path, notice: "Bienvenido, #{user.name}."
    else
      flash.now[:alert] = "El correo o la contraseña no son correctos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Cerraste sesión correctamente."
  end
end
