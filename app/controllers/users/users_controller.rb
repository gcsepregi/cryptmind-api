# frozen_string_literal: true

module Users
  class UsersController < ApplicationController
    def me
      render json: {
        id: current_user.id,
        email: current_user.email,
        nickname: current_user.nickname,
        picture: nil
      }, status: :ok
    end
  end
end
