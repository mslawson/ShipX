require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/prawn_outputter'

class ShipmentsController < ApplicationController

  before_filter :authenticate_user!, :only => [:track, :pdf]

  def create
    if user_signed_in?
      @shipment = Shipment.create(user_token: session[:user_token], user_id: current_user.id)
    else
      @shipment = Shipment.create(user_token: session[:user_token])
    end
    redirect_to edit_shipment_shipment_part_path(@shipment, "location_info")
  end

  def track

    @shipment = Shipment.find(params[:id])
    raise "Not allowed" unless @shipment.user_id == current_user.id

  end

  def pdf

    shipment = Shipment.find(params[:id])
    raise "Not allowed" unless shipment.user_id == current_user.id
    pro = "000000"
    pdf_file = Prawn::Document.new do

      x = 30
      y = 680
      width = 200
      height = 150

      stroke_rectangle [30,y+20], width, height

      text_box '<u>Origin Address</u>', :at => [x+10, y-10], :width => width-20, :inline_format => true
      text_box shipment.origin_address.as_html_block, :at => [x+10, y-30], :width => width-20, :inline_format => true

      y = y - height - 50

      stroke_rectangle [30,y+20], width, height
      text_box '<u>Destination Address</u>', :at => [x+10, y-10], :width => width-20, :inline_format => true
      text_box shipment.destination_address.as_html_block, :at => [x+10, y-30], :width => width-20, :inline_format => true


      x = 300
      y = 680
      text_box "<b>BOL:</b><br/>#{shipment.bol}", :at => [x+10, y-10], :width => width, :inline_format => true

      x = 300
      y = 630
      text_box "Unit ______ of _______", :at => [x+10, y-10], :width => width, :inline_format => true

      y = y - height
      text_box "<b>PRO:</b><br/>#{pro}", :at => [x+10, y-10], :width => width, :inline_format => true

    end

    barcode = Barby::Code128B.new pro
    barcode.annotate_pdf(pdf_file, :x => 320, :y => 380)

    send_data pdf_file.render, type: 'application/pdf', disposition: 'inline'

  end

end