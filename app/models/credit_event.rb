class CreditEvent < ActiveRecord::Base

  CREDIT_EVENT_STATUS_OPEN = 0
  CREDIT_EVENT_STATUS_CLOSED = 1

  belongs_to :credit_application
  belongs_to :shipment

  scope :open, -> { where(status: CREDIT_EVENT_STATUS_OPEN) }

  after_save :update_credit_application_available_credit

  def is_open?
    self.status == CREDIT_EVENT_STATUS_OPEN
  end

  def is_closed?
    self.status == CREDIT_EVENT_STATUS_CLOSED
  end

  private

  def update_credit_application_available_credit
    self.credit_application.update_available_credit
  end

end
