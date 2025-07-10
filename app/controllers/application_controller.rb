class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :update_user_session

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :email, :password, :password_confirmation ])
  end

  def update_user_session
    return unless current_user

    jti = request_jwt_jti
    current_session = current_user.user_sessions.find_by(jwt_jti: jti)
    current_session&.touch(:last_seen_at)
  end

  def request_jwt_jti
    token = request.headers["Authorization"]&.split(" ")&.last
    return nil unless token

    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.devise[:jwt_secret_key], true, algorithm: "HS256")
      decoded_token.first["jti"]
    rescue JWT::DecodeError
      nil
    end
  end
end
