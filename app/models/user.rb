class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :shipments
  has_many :payment_methods
  has_one :credit_application

  def has_approved_credit_line?
    self.credit_application && self.credit_application.approved?
  end

  def loc_payment_method
    self.payment_methods.where(payment_method_type: PaymentMethod::PAYMENT_METHOD_TYPE_LOC).first
  end

end
