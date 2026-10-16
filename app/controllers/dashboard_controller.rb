class DashboardController < ApplicationController
  def index
    @converters = current_user.available_converters
  end
end
