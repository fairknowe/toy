# frozen_string_literal: true

class Subscription < ApplicationRecord
  has_many :subscription_line_items, dependent: :destroy

  # validates :name, :status, :current_period_end, presence: true
  # Scopes
  # scope :active, -> { where(status: 'active') }
  before_save :set_default_values

  private

  def set_default_values
    self.test ||= true
  end
end
