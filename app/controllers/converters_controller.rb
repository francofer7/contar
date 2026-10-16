class ConvertersController < ApplicationController
  # These are immutable, allowlisted vendor files rather than user-specific JS responses.
  skip_forgery_protection only: :asset

  def show
    converter = Converter.active.find_by!(key: params[:key])

    unless current_user.admin? || current_user.assigned_converters.exists?(converter.id)
      redirect_to root_path, alert: "Ese convertidor no está asignado a tu usuario."
      return
    end

    source_path = case converter.key
    when "extractos-bancarios" then converter_path("banking.html")
    when "tarjetas-credito" then converter_path("cards.html")
    else raise ActionController::RoutingError, "Not Found"
    end

    send_file source_path, type: "text/html; charset=utf-8", disposition: "inline"
  end

  def asset
    asset_path = case params[:filename]
    when "pdf.min.js" then converter_path("vendor", "pdf.min.js")
    when "pdf.worker.min.js" then converter_path("vendor", "pdf.worker.min.js")
    when "xlsx.full.min.js" then converter_path("vendor", "xlsx.full.min.js")
    else raise ActionController::RoutingError, "Not Found"
    end

    send_file asset_path, type: "application/javascript", disposition: "inline"
  end

  private

  def converter_path(*parts)
    Rails.root.join("lib", "converters", *parts)
  end
end
