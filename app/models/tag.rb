class Tag < ApplicationRecord
  belongs_to :user
  has_many :journal_entry_tags
  has_many :journal_entries, through: :journal_entry_tags

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
