class Shipment::Summary < Shipment

  validates_presence_of :hazardous_materials_phone, :if => :hazardous?
  validates_presence_of :origin_address, :destination_address

  @user = nil

  before_save :user_account

  def user_account

    unless user_signed_in == true
      Rails.logger.info "what now?"

      if self.login_email.present? && self.login_password.present?
        # login
        user = User.where(email: self.login_email).first
        if user.nil?
          self.errors.add(:account, "email not found")
          return false
        end

        if user.valid_password?(self.login_password)
          @user = user
        else
          self.errors.add(:account, "password invalid")
        end

      elsif self.register_email.present? && self.register_password.present? && self.register_password_confirmation.present?
        # create
        begin
          @user = User.new(email: self.register_email,
                            password: self.register_password,
                            password_confirmation: self.register_password_confirmation)
          #sign_in @user
          @user.save

          if !@user.valid?
            self.errors.add(:account, @user.errors.to_a.join(", "))
            return false
          end

        end
      else
        self.errors.add(:account, "must either login or create an account")
        return false
      end

    end

  end

  def user
    @user
  end

end