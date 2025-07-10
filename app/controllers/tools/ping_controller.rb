# frozen_string_literal: true

module Tools
  class PingController < ApplicationController
    respond_to :json

    def index
      render json: { pong: true }, status: :ok
    end
  end
end
