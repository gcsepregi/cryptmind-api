# frozen_string_literal: true

module Admin
  class UsersController < AdminControllerBase

    def index
      @user = User.all
      render json: @user.as_json, status: :ok
    end

  end
end
