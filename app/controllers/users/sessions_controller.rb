# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: { message: "Logged in.", user: resource }, status: :ok
    end

    def respond_to_on_destroy
      jwt_payload = JWT.decode(request.headers["Authorization"].split(" ").last,
                               Rails.application.credentials.devise[:jwt_secret_key])[0]
      current_user = User.find(jwt_payload["sub"])
      if current_user
        render json: { message: "Logged out." }, status: :ok
      else
        render json: { message: "Failed to log out." }, status: :unauthorized
      end
    end
  end
end
