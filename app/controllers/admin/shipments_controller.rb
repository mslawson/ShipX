class Admin::ShipmentsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :admin_only

  def index

    @credit_apps = CreditApplication.pending

    @booked_count = Hash.new
    @booked_count['0-30'] = Shipment.where(created_at: 30.days.ago.to_date..Date.today).complete.count
    @booked_count['31-60'] = Shipment.where(created_at: 60.days.ago.to_date..30.days.ago.to_date).complete.count
    @booked_count['61-90'] = Shipment.where(created_at: 90.days.ago.to_date..60.days.ago.to_date).complete.count
    @booked_count['90+'] = Shipment.where("created_at < ?", 90.days.ago.to_date).complete.count

    @booked_amount = Hash.new
    @booked_amount['0-30'] = Shipment.where(created_at: 30.days.ago.to_date..Date.today).complete.to_a.sum { |s| s.total_price.to_f }
    @booked_amount['31-60'] = Shipment.where(created_at: 60.days.ago.to_date..30.days.ago.to_date).complete.to_a.sum { |s| s.total_price.to_f }
    @booked_amount['61-90'] = Shipment.where(created_at: 90.days.ago.to_date..60.days.ago.to_date).complete.to_a.sum { |s| s.total_price.to_f }
    @booked_amount['90+'] = Shipment.where("created_at < ?", 90.days.ago.to_date).complete.to_a.sum { |s| s.total_price.to_f }

    @shipments = Shipment.booked.paginate(page: params[:page])

  end

  def show

    @shipment = Shipment.find(params[:id])

  end

  def new_charge
    @shipment = Shipment.find(params[:id])
  end

  def do_new_charge

    @shipment = Shipment.find(params[:id])

    @payment_method = @shipment.payment_method.rebill_id

    charge_amount = params[:amount].to_f
    shipx_fee = ConfigurationItem.addon_shipx_fee
    service_fee = (charge_amount * ConfigurationItem.var_service_fee).round(2) + ConfigurationItem.fixed_service_fee
    amount = (charge_amount + service_fee + shipx_fee).round(2).to_s.gsub(/[^0-9.]/, '')

    begin
      debit = Stripe::Charge.create(
          amount: (amount.to_f * 100).to_i,
          customer: @shipment.user.stripe_id,
          currency: 'usd',
          source: @payment_method,
          statement_descriptor: "ShipX Adjustment ##{@shipment.id}",
          description: "Shipment Adj #{@shipment.id}",
          destination: ConfigurationItem.default_merchant_account,
          application_fee: ((shipx_fee + service_fee)*100).to_i,
      )
    rescue => e
      flash[:alert] = "Error making charge! #{e.to_s}"
      render :new_charge
      return
    end

    payment = Payment.create(
               shipment_id: @shipment.id,
               payment_method_id: @shipment.payment_method_id,
               status: Payment::PAYMENT_STATUS_SUCCESS,
               transaction_id: debit.id,
               amount: (debit.amount.to_f/100).round(2)
    )

    PaymentSplit.create(
        payment_id: payment.id,
        amount: charge_amount,
        fund: PaymentSplit::PAYMENT_SPLIT_CARRIER_PORTION
    )
    PaymentSplit.create(
        payment_id: payment.id,
        amount: shipx_fee,
        fund: PaymentSplit::PAYMENT_SPLIT_SHIPX_FEE
    )
    PaymentSplit.create(
        payment_id: payment.id,
        amount: service_fee,
        fund: PaymentSplit::PAYMENT_SPLIT_SHIPX_SERVICE_FEE
    )

    redirect_to admin_shipment_path(@shipment)

  end

  def complete_order

    begin

      @shipment = Shipment.find(params[:id])
      @shipment.status = Shipment::SHIPMENT_STATUS_DELIVERED
      @shipment.save

    rescue => e
      redirect_to admin_shipments_path, :alert => e and return
    end

    redirect_to admin_shipments_path, :notice => "Order Completed"

  end

end