# frozen_string_literal: true

module Admin
  class UsersController < AdminControllerBase

    def index
      @user = User
      respond_index @user
    end

  end
end
