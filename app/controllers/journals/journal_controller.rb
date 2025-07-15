# frozen_string_literal: true

module Journals
  class JournalController < ApplicationController
    respond_to :json

    def index
      @journals = Journal.where(user_id: current_user.id).order(created_at: :desc)
      render json: @journals.to_json, status: :ok
    end

    def create
      @entry = Journal.new(journal_entry_params)
      @entry.user = current_user
      @entry.save!
      render status: :created
    end

    protected

    def journal_entry_params
      params.expect(journal: [:entry])
    end
  end
end
