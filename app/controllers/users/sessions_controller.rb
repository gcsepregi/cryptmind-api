# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)

      # Build JWT payload the same way devise-jwt does
      token = request.env["warden-jwt_auth.token"]
      payload = Warden::JWTAuth::TokenDecoder.new.call(token)
      jti = payload["jti"]

      resource.user_sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
        last_seen_at: Time.current,
        jwt_jti: jti
      )

      respond_with resource
    end

    private

    def respond_with(resource, _opts = {})
      render json: { message: "Logged in.", user: resource }, status: :ok
    end

    def respond_to_on_destroy
      jwt_payload = JWT.decode(request.headers["Authorization"].split(" ").last,
                               ENV["DEVISE_JWT_SECRET"] ||
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
