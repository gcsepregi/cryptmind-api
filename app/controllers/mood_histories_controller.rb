class MoodHistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mood_history, only: [ :show, :update, :destroy ]
  
  # POST /mood_histories/sync
  def sync
    if params[:mood_histories].present?
      # Handle bulk sync
      results = []
      errors = []
      
      params[:mood_histories].each do |mood_data|
        client_id = mood_data[:id] || mood_data["id"]
        mood = mood_data[:mood] || mood_data["mood"]
        recorded_at = mood_data[:recorded_at] || mood_data["recorded_at"]
        
        mood_history = current_user.mood_histories.find_or_initialize_by(client_id: client_id)
        mood_history.mood = mood
        mood_history.recorded_at = recorded_at
        
        if mood_history.save
          results << mood_history
        else
          errors << { client_id: client_id, errors: mood_history.errors.full_messages }
        end
      end
      
      if errors.empty?
        render json: { success: true, mood_histories: results }, status: :ok
      else
        render json: { success: false, errors: errors }, status: :unprocessable_entity
      end
    else
      # Handle single sync (backward compatibility)
      client_id = params[:id]
      mood = params[:mood]
      recorded_at = params[:recorded_at]
      
      @mood_history = current_user.mood_histories.find_or_initialize_by(client_id: client_id)
      @mood_history.mood = mood
      @mood_history.recorded_at = recorded_at
      
      if @mood_history.save
        render json: @mood_history, status: @mood_history.previous_changes.any? ? :ok : :created
      else
        render json: { errors: @mood_history.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # GET /mood_histories
  def index
    @mood_histories = current_user.mood_histories.order(recorded_at: :desc)

    if params[:from_date].present? && !params[:from_date].empty?
      @mood_histories = @mood_histories.where("recorded_at >= ?", Date.parse(params[:from_date].to_s).beginning_of_day)
    end

    if params[:to_date].present? && !params[:to_date].empty?
      @mood_histories = @mood_histories.where("recorded_at <= ?", Date.parse(params[:to_date].to_s).end_of_day)
    end

    render json: @mood_histories
  end

  # GET /mood_histories/:id
  def show
    render json: @mood_history
  end

  # POST /mood_histories
  def create
    @mood_history = current_user.mood_histories.new(mood_history_params)

    if @mood_history.save
      render json: @mood_history, status: :created
    else
      render json: { errors: @mood_history.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mood_histories/:id
  def update
    if @mood_history.update(mood_history_params)
      render json: @mood_history
    else
      render json: { errors: @mood_history.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /mood_histories/:id
  def destroy
    @mood_history.destroy
    head :no_content
  end

  private

  def set_mood_history
    @mood_history = current_user.mood_histories.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Mood history not found" }, status: :not_found
  end

  def mood_history_params
    params.require(:mood_history).permit(:mood, :recorded_at, :notes, :journal_entry_id, :client_id)
  end
end
