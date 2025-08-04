# frozen_string_literal: true

module Admin
  class UsersController < AdminControllerBase

    def index
      @user = User
                .left_joins(:user_sessions, :journal_entries)
                .select(
                  "users.*",
                  "COUNT(DISTINCT CASE WHEN user_sessions.jwt_jti IS NOT NULL AND user_sessions.jwt_jti NOT IN (SELECT jti FROM jwt_denylists) THEN user_sessions.id END) AS sessions_count",
                  "COUNT(DISTINCT journal_entries.id) AS journals_count"
                )
                .group("users.id")

      render json: @user.as_json, status: :ok
    end

  end
end
