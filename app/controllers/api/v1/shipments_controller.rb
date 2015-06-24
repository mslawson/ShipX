class Api::V1::ShipmentsController < ApplicationController

  def show
    @shipment = Shipment.find(params[:id])
    # @TODO: authentication
    render json: @shipment
  end

end