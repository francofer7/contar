module ApplicationHelper
  def role_label(user)
    user.admin? ? "Administrador" : "Operario"
  end

  def initials(name)
    name.split.first(2).filter_map(&:first).join.upcase
  end
end
