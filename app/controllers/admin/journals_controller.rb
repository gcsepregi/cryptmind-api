# frozen_string_literal: true

module Admin
  class JournalsController < AdminControllerBase
    def index
      respond_index User.find(params[:user_id]).journal_entries
    end
  end
end
