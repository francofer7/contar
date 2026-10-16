module Admin
  class UsersController < ApplicationController
    before_action :require_admin
    before_action :set_user, only: %i[edit update destroy]
    before_action :load_converters, only: %i[new create edit update]

    def index
      @users = User.includes(:assigned_converters).order(:name)
    end

    def new
      @user = User.new(role: :operator, active: true)
    end

    def create
      @user = User.new(account_params)

      User.transaction do
        @user.save!
        assign_converters
      end

      redirect_to admin_users_path, notice: "Usuario creado correctamente."
    rescue ActiveRecord::RecordInvalid
      render :new, status: :unprocessable_entity
    end

    def edit
    end

    def update
      if unsafe_admin_change?
        render :edit, status: :unprocessable_entity
        return
      end

      User.transaction do
        @user.update!(account_params)
        assign_converters
      end

      redirect_to admin_users_path, notice: "Usuario actualizado correctamente."
    rescue ActiveRecord::RecordInvalid
      render :edit, status: :unprocessable_entity
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path, alert: "No podés eliminar tu propio usuario."
      elsif last_active_admin?(@user)
        redirect_to admin_users_path, alert: "No podés eliminar al último administrador activo."
      else
        @user.destroy!
        redirect_to admin_users_path, notice: "Usuario eliminado."
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def load_converters
      @converters = Converter.active.ordered
    end

    def account_params
      return @account_params if defined?(@account_params)

      submitted = params.require(:user)
      attributes = submitted.permit(:name, :email, :password, :password_confirmation)
      attributes[:role] = submitted[:role] if User.roles.key?(submitted[:role])
      attributes[:active] = ActiveModel::Type::Boolean.new.cast(submitted[:active]) if submitted.key?(:active)
      attributes = attributes.except(:password, :password_confirmation) if attributes[:password].blank?
      @account_params = attributes
    end

    def assign_converters
      ids = params.require(:user).permit(converter_ids: [])[:converter_ids]
      ids = Converter.active.where(id: ids).ids
      @user.converter_ids = ids
    end

    def unsafe_admin_change?
      requested_role = account_params[:role]
      requested_active = ActiveModel::Type::Boolean.new.cast(account_params[:active])
      removes_admin_access = requested_role.present? && requested_role != "admin"
      removes_admin_access ||= account_params.key?(:active) && !requested_active

      return false unless removes_admin_access

      if @user == current_user
        @user.errors.add(:base, "No podés quitarte tu propio acceso de administrador.")
        true
      elsif last_active_admin?(@user)
        @user.errors.add(:base, "Debe quedar al menos un administrador activo.")
        true
      else
        false
      end
    end

    def last_active_admin?(user)
      user.admin? && user.active? && User.admin.active.where.not(id: user.id).none?
    end
  end
end
