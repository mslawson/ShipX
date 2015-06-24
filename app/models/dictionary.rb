class Dictionary < ActiveRecord::Base
  has_many :dictionary_entries
  validates_presence_of :name, :code

  class << self

    def for_code(code)
      dict = Dictionary.where(code: code).first
      return nil unless dict
      return dict.dictionary_entries
    end

  end
end
