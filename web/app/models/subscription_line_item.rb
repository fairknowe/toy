# frozen_string_literal: true

class SubscriptionLineItem < ApplicationRecord
  belongs_to :subscription
end
