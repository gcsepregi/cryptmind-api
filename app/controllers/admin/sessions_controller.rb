# frozen_string_literal: true

module Admin
  class SessionsController < AdminControllerBase
    def index
      @user = User.find(params[:user_id])
      active_sessions = @user.user_sessions.where.not(jwt_jti: JwtDenylist.select(:jti))
      render json: @user.as_json.merge(user_sessions: active_sessions.as_json), status: :ok
    end

    def destroy
      user = User.find(params[:user_id])
      session = user.user_sessions.find_by(jwt_jti: params[:id])

      if session
        jwt_exp = request_jwt_exp
        exp = Time.at(jwt_exp).to_datetime if jwt_exp
        JwtDenylist.create!(jti: session.jwt_jti, exp: exp)
        render status: :no_content
      else
        render status: :not_found
      end
    end
  end
end
