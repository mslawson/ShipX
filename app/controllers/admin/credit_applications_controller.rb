class Admin::CreditApplicationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :admin_only

  def index
    if params[:status] && (params[:status].to_i != -1)
      @credit_applications = CreditApplication.where(status: params[:status]).paginate(:page => params[:page])
    else
      @credit_applications = CreditApplication.paginate(:page => params[:page])
    end
    @status = params[:status].to_i
  end

  def show
    @credit_application = CreditApplication.find(params[:id])
  end

  def update
    @credit_application = CreditApplication.find(params[:id])

    if (params[:commit] == "Approve") || (params[:commit] == "Save Changes")
      CreditApplicationMailer.app_approved(@credit_application).deliver
      @credit_application.status = CreditApplication::STATUS_APPROVED
      unless @credit_application.payment_method
        PaymentMethod.create(user_id: @credit_application.user_id,
                             payment_method_type: PaymentMethod::PAYMENT_METHOD_TYPE_LOC,
                             credit_application_id: @credit_application.id)
      end
    elsif (params[:commit] == "Deny") || (params[:commit] == "Revoke Credit")
      CreditApplicationMailer.app_rejected(@credit_application).deliver
      @credit_application.status = CreditApplication::STATUS_DENIED
    end

    respond_to do |format|
      if @credit_application.update(credit_application_params)
        format.html { redirect_to '/admin', notice: 'Application was successfully updated.' }
        format.json { render :show, status: :ok, location: @credit_application }
      else
        format.html { render :edit }
        format.json { render json: @credit_application.errors, status: :unprocessable_entity }
      end
    end
  end

  def mark_as_paid
    event = CreditEvent.find(params[:id])
    event.status = CreditEvent::CREDIT_EVENT_STATUS_CLOSED
    event.save
    redirect_to admin_credit_application_path(event.credit_application)
  end

  private

  def credit_application_params
    params.require(:credit_application).permit(:approved_credit_line, :message)
  end

end
