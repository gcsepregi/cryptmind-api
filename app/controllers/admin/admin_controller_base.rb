# frozen_string_literal: true

class Admin::AdminControllerBase < ApplicationController
  before_action :authorize_admin!

  private

  def authorize_admin!
    authorize :admin_area, :access?
  end
end
