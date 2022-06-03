# frozen_string_literal: true

class Import < ApplicationRecord
  belongs_to :user
  has_many :contacts
end
