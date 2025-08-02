# frozen_string_literal: true

module Admin
  class DashboardController < Admin::AdminControllerBase
    def index
      render json: { "hello": "world" }, status: :ok
    end
  end
end
