class JournalEntry < ApplicationRecord
  belongs_to :user
  has_many :journal_entry_tags
  has_many :tags, through: :journal_entry_tags

  enum :journal_type, { diary: 0, dream: 1, ritual: 2, divination: 3 }
end
