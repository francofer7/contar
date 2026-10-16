converters = [
  {
    key: "extractos-bancarios",
    name: "Extractos bancarios",
    description: "Transforma extractos PDF, Excel o CSV en movimientos ordenados y valida saldos y totales.",
    source_file: "banking.html",
    position: 1,
    active: true
  },
  {
    key: "tarjetas-credito",
    name: "Tarjetas de crédito",
    description: "Extrae consumos y gastos de resúmenes de tarjeta y reconcilia el total a pagar.",
    source_file: "cards.html",
    position: 2,
    active: true
  }
]

converters.each do |attributes|
  converter = Converter.find_or_initialize_by(key: attributes[:key])
  converter.update!(attributes)
end

if Rails.env.production?
  admin_email = ENV.fetch("CONTAR_ADMIN_EMAIL")
  admin_password = ENV.fetch("CONTAR_ADMIN_PASSWORD")
else
  admin_email = ENV.fetch("CONTAR_ADMIN_EMAIL", "admin@contar.local")
  admin_password = ENV.fetch("CONTAR_ADMIN_PASSWORD", "Cambiar123!")
end
admin = User.find_or_initialize_by(email: admin_email)
admin.assign_attributes(name: "Administrador", role: :admin, active: true)
admin.password = admin_password if admin.new_record?
admin.password_confirmation = admin_password if admin.new_record?
admin.save!

puts "Contar listo. Administrador: #{admin.email}"
puts "Contraseña inicial: #{admin_password}" if !Rails.env.production? && ENV["CONTAR_ADMIN_PASSWORD"].blank?
