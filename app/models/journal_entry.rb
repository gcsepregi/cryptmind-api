class JournalEntry < ApplicationRecord
  belongs_to :user
  has_many :journal_entry_tags, dependent: :destroy
  has_many :tags, through: :journal_entry_tags

  enum :journal_type, { diary: 0, dream: 1, ritual: 2, divination: 3 }
  
  # Define JSON fields as arrays
  attribute :gratitude_list, :json, default: []
  attribute :achievements, :json, default: []
  attribute :dream_signs, :json, default: []
  attribute :dream_characters, :json, default: []
  attribute :dream_emotions, :json, default: []
  attribute :ritual_tools, :json, default: []
  attribute :ritual_deities, :json, default: []
  
  # Validations for numeric fields
  validates :lucidity_level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  validates :dream_clarity, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  validates :ritual_duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Ensure JSON fields are always arrays
  before_validation :ensure_json_arrays
  
  private
  
  def ensure_json_arrays
    self.gratitude_list = [] if gratitude_list.nil?
    self.achievements = [] if achievements.nil?
    self.dream_signs = [] if dream_signs.nil?
    self.dream_characters = [] if dream_characters.nil?
    self.dream_emotions = [] if dream_emotions.nil?
    self.ritual_tools = [] if ritual_tools.nil?
    self.ritual_deities = [] if ritual_deities.nil?
  end
end
