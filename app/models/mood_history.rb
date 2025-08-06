class MoodHistory < ApplicationRecord
  belongs_to :user
  belongs_to :journal_entry, optional: true

  validates :mood, presence: true
  validates :recorded_at, presence: true

  # Scope to get mood entries for a specific date range
  scope :in_date_range, ->(start_date, end_date) {
    where(recorded_at: start_date.beginning_of_day..end_date.end_of_day)
  }

  # Scope to get mood entries for a specific day
  scope :on_date, ->(date) {
    where(recorded_at: date.beginning_of_day..date.end_of_day)
  }
end
