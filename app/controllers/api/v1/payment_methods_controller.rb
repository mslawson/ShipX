class Api::V1::PaymentMethodsController < ApplicationController

  before_filter :authenticate_user!

  def create

    user = current_user

    customer = nil

    if user.stripe_id
      customer = Stripe::Customer.retrieve(user.stripe_id)
    else
      customer = Stripe::Customer.create(
          email: user.email,
          source: params[:token_id]
      )
      user.stripe_id = customer.id
      user.save
    end

    rebill_id = nil
    customer.sources.each do |source|
      if ((source.object == 'card') &&
          (source.last4.to_i == params[:cc_last_four].to_i) &&
          (source.exp_month.to_i == params[:expiration_month].to_i) &&
          (source.exp_year.to_i == params[:expiration_year].to_i))
        rebill_id = source.id
      end
    end

    if rebill_id && (pmt = PaymentMethod.create(
        user_id: user.id,
        payment_method_type: PaymentMethod::PAYMENT_METHOD_TYPE_CC,
        rebill_id: rebill_id,
        saved: true,
        cc_expiration_month: params[:expiration_month],
        cc_expiration_year: params[:expiration_year],
        cc_last_four: params[:cc_last_four]
    ))
      render :json => pmt, status: 201
    else
      render :json => pmt, status: 500
    end

  end

end