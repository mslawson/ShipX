class DictionaryEntry < ActiveRecord::Base
  belongs_to :dictionary
  validates_presence_of :dictionary_id, :name, :key
end
