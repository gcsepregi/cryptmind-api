class JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journal_type, except: [ :all, :recents, :stats ]
  before_action :set_journal_entry, only: [ :show, :update, :destroy ]

  # Helper method to replace numeric id with hashid in JSON response
  def replace_id_with_hashid(json_data)
    if json_data.is_a?(Array)
      json_data.map do |item|
        replace_id_with_hashid(item)
      end
    elsif json_data.is_a?(Hash)
      if json_data.key?("hashid")
        json_data["id"] = json_data["hashid"]
        json_data.delete("hashid")
      end

      # Process nested objects like tags
      json_data.each do |key, value|
        if value.is_a?(Array) || value.is_a?(Hash)
          json_data[key] = replace_id_with_hashid(value)
        end
      end

      json_data
    else
      json_data
    end
  end

  def all
    @journal_entries = current_user.journal_entries.includes(:tags)
    if params[:from_date].present? and !params[:from_date].empty?
      @journal_entries = @journal_entries.where("created_at >= ?", Date.parse(params[:from_date].to_s))
    end

    if params[:to_date].present? and !params[:to_date].empty?
      @journal_entries = @journal_entries.where("created_at <= ?", Date.parse(params[:to_date].to_s).end_of_day)
    end

    if params[:type].present? and params[:type] != "all"
      @journal_entries = @journal_entries.where(journal_type: params[:type])
    end

    if params[:search].present?
      @journal_entries = @journal_entries.where("title LIKE ? OR entry LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    json_data = @journal_entries.order("created_at DESC").as_json(include: { tags: { methods: [ :hashid ], only: [ :name ] } }, methods: [ :hashid ], only: [ :title, :entry, :created_at ])
    render json: replace_id_with_hashid(json_data)
  end

  # GET /journals/:journal_type/:id
  def show
    json_data = @journal_entry.as_json(include: :tags, methods: [ :hashid ])
    render json: replace_id_with_hashid(json_data)
  end

  # POST /journals/:journal_type
  def create
    @journal_entry = current_user.journal_entries.new(journal_entry_params.merge(journal_type: @journal_type))
    if @journal_entry.save
      process_tags(@journal_entry)
      json_data = @journal_entry.as_json(include: :tags, methods: [ :hashid ])
      render json: replace_id_with_hashid(json_data), status: :created
    else
      render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /journals/:journal_type/:id
  def update
    if @journal_entry.update(journal_entry_params)
      process_tags(@journal_entry)
      json_data = @journal_entry.as_json(include: :tags, methods: [ :hashid ])
      render json: replace_id_with_hashid(json_data)
    else
      render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /journals/:journal_type/:id
  def destroy
    @journal_entry.destroy
    head :no_content
  end

  def recents
    @journal_entries = current_user.journal_entries.includes(:tags).order("created_at DESC").limit(3)
    json_data = @journal_entries.as_json(include: :tags, methods: [ :hashid ])
    render json: replace_id_with_hashid(json_data)
  end

  def stats
    @stats = current_user.journal_entries.group("journal_type").count
    @total = current_user.journal_entries.count
    render json: { stats: @stats, total: @total }
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
