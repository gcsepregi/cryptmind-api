class JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journal_type, except: [ :all, :recents, :stats ]
  before_action :set_journal_entry, only: [ :show, :update, :destroy ]

  # Helper method to replace numeric id with hashid in JSON response
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

    json_data = @journal_entries.order("created_at DESC").as_json(include: { tags: { methods: [ :hashid ], only: [ :name ] } }, methods: [ :hashid ], only: [ :title, :entry, :created_at, :journal_type ])
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
      save_mood_history(@journal_entry) if @journal_entry.mood.present?
      json_data = @journal_entry.as_json(include: :tags, methods: [ :hashid ])
      render json: replace_id_with_hashid(json_data), status: :created
    else
      render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /journals/:journal_type/:id
  def update
    old_mood = @journal_entry.mood
    if @journal_entry.update(journal_entry_params)
      process_tags(@journal_entry)
      # Only save mood history if mood has changed
      if @journal_entry.mood.present? && @journal_entry.mood != old_mood
        save_mood_history(@journal_entry)
      end
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
    @journal_entry = current_user.journal_entries.find_by_hashid!(params[:id])
    render json: { error: "Invalid journal entry" }, status: :bad_request unless @journal_entry.journal_type == @journal_type
  end

  def journal_entry_params
    permitted_params = [ :title, :entry, :is_private ]

    # Common Optional Metadata
    permitted_params += [ :mood, :location ]

    # Type-specific fields based on journal_type
    case @journal_type
    when "diary"
      permitted_params += [ :diary_date, { gratitude_list: [], achievements: [] } ]
    when "dream"
      permitted_params += [ :dream_date, :lucidity_level, :dream_clarity, { dream_signs: [], dream_characters: [], dream_emotions: [] } ]
    when "ritual"
      permitted_params += [ :ritual_date, :ritual_type, :ritual_purpose, :ritual_outcome, :ritual_duration, { ritual_tools: [], ritual_deities: [] } ]
    end

    params.require(:journal_entry).permit(permitted_params)
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

  # Save mood information to mood_histories table
  def save_mood_history(journal_entry)
    current_user.mood_histories.create(
      mood: journal_entry.mood,
      journal_entry: journal_entry,
      recorded_at: journal_entry.created_at,
      notes: "Extracted from #{journal_entry.journal_type} journal entry: #{journal_entry.title}"
    )
  end
end
