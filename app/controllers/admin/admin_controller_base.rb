# frozen_string_literal: true

class Admin::AdminControllerBase < ApplicationController
  before_action :authorize_admin!

  private

  def respond_index(data)
    index = params[:page_index].to_i || 0
    page_size = params[:page_size].to_i || 10
    order = params[:order_by] || "id"
    order_direction = params[:order_direction] || "asc"
    render json: {
      data: data.order(order.to_sym => order_direction.to_sym).limit(page_size).offset(index * page_size).as_json,
      pageIndex: index,
      pageSize: page_size,
      total: data.count
    }
  end

  def authorize_admin!
    authorize :admin_area, :access?
  end
end
