class CreditApplication < ActiveRecord::Base

  STATUS_PENDING = 0
  STATUS_APPROVED = 1
  STATUS_DENIED = 2

  belongs_to :user

  scope :pending, -> { where(status: STATUS_PENDING) }

  has_many :credit_events
  has_one :payment_method

  validates_presence_of :company_name, :contact_name, :title, :phone_number, :company_address_1, :city, :state, :zip_code,:requested_credit_line

  def pending?
    status == STATUS_PENDING
  end

  def approved?
    status == STATUS_APPROVED
  end

  def denied?
    status == STATUS_DENIED
  end

  def update_available_credit
    credit_in_use = 0
    self.credit_events.open.each do |event|
      credit_in_use += event.amount
    end
    if credit_in_use > self.approved_credit_line
      raise "Credit limit exceeded"
    else
      self.available_credit = self.approved_credit_line - credit_in_use
      self.save
    end
  end

end