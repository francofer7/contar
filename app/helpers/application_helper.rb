module ApplicationHelper
  def role_label(user)
    user.admin? ? "Administrador" : "Operario"
  end

  def initials(name)
    name.split.first(2).filter_map(&:first).join.upcase
  end

  def whatsapp_url(phone, message: nil)
    url = "https://wa.me/#{phone.to_s.gsub(/\D/, "")}"
    message.present? ? "#{url}?text=#{ERB::Util.url_encode(message)}" : url
  end

  def phone_country_options
    User::PHONE_COUNTRY_CODES.sort_by { |country| country == "AR" ? "" : country }.map do |country|
      calling_code = Phonelib.phone_data.fetch(country)[:country_code]
      [ "#{country_flag(country)} #{country} +#{calling_code}", country ]
    end
  end

  def local_phone_value(user)
    parsed = Phonelib.parse(user.phone)
    return user.phone unless parsed.valid?

    number = parsed.national_number
    user.phone_country == "AR" && parsed.type == :mobile ? number.delete_prefix("9") : number
  end

  def country_flag(country)
    country.codepoints.map { |codepoint| (codepoint + 127_397).chr(Encoding::UTF_8) }.join
  end

  def access_message(name:, email:, password: nil)
    lines = [
      "Hola #{name.split.first}, ya creamos tu acceso a Contar.",
      "Ingresá en: #{login_url}",
      "Usuario: #{email}"
    ]
    lines << "Contraseña temporal: #{password}" if password.present?
    lines << "Guardá estos datos en un lugar seguro."
    lines.join("\n")
  end
end
