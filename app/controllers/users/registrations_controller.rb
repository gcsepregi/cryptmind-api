# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    def create
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?

      respond_with resource
    end

    private

    def respond_with(resource, _opts = {})
      if resource.persisted?
        token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first
        render json: {
          message: "Signed up successfully.",
          token: token,
          user: resource
        }, status: :ok
      else
        render json: {
          message: "Signup failed.",
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end
end
