class JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journal_type
  before_action :set_journal_entry, only: [ :show, :update, :destroy ]

  # GET /journals/:journal_type
  def index
    @journal_entries = current_user.journal_entries.where(journal_type: @journal_type).includes(:tags)
    render json: @journal_entries.as_json(include: :tags)
  end

  # GET /journals/:journal_type/:id
  def show
    render json: @journal_entry.as_json(include: :tags)
  end

  # POST /journals/:journal_type
  def create
    @journal_entry = current_user.journal_entries.new(journal_entry_params.merge(journal_type: @journal_type))
    if @journal_entry.save
      process_tags(@journal_entry)
      render json: @journal_entry.as_json(include: :tags), status: :created
    else
      render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /journals/:journal_type/:id
  def update
    if @journal_entry.update(journal_entry_params)
      process_tags(@journal_entry)
      render json: @journal_entry.as_json(include: :tags)
    else
      render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /journals/:journal_type/:id
  def destroy
    @journal_entry.destroy
    head :no_content
  end

  private

  def set_journal_type
    types = JournalEntry.journal_types.keys
    @journal_type = params[:journal_type]
    render json: { error: "Invalid journal type" }, status: :bad_request unless types.include?(@journal_type)
  end

  def set_journal_entry
    @journal_entry = current_user.journal_entries.find_by!(id: params[:id], journal_type: @journal_type)
  end

  def journal_entry_params
    params.require(:journal_entry).permit(:title, :entry, :is_private)
  end

  # Handles tag creation/association for a journal entry
  def process_tags(journal_entry)
    if params[:journal_entry][:tags]
      tag_names = params[:journal_entry][:tags].map(&:strip).uniq
      tags = tag_names.map do |name|
        current_user.tags.find_or_create_by(name: name)
      end
      journal_entry.tags = tags
    end
  end
end
