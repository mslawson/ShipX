class CreditApplicationsController < ApplicationController

  before_filter :authenticate_user!

  def index
    if current_user.credit_application
      redirect_to current_user.credit_application
    else
      redirect_to new_credit_application_path
    end
  end

  def show
    @credit_application = CreditApplication.find(params[:id])
  end

  def new
    @credit_application = CreditApplication.new
  end

  def create
    @credit_application = CreditApplication.new(credit_application_params)
    @credit_application.status = CreditApplication::STATUS_PENDING
    @credit_application.user_id = current_user.id
    if @credit_application.save
      CreditApplicationMailer.app_submitted(@credit_application).deliver
      redirect_to @credit_application, :notice => "Successfully created credit application."
    else
      render :action => 'new'
    end
  end

  private

  def credit_application_params
    params.require(:credit_application).permit(:company_name, :alternate_name, :requested_credit_line, :contact_name, :title, :phone_number, :company_address_1, :company_address_2, :city, :state, :zip_code)
  end

end
