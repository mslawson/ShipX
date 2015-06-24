class Admin::ConfigurationItemsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :admin_only

  def index

  end

  def edit

    @configuration_item = ConfigurationItem.where(configuration_key: params[:id]).first

  end

  def update
    @configuration_item = ConfigurationItem.find(params[:id])
    @configuration_item.configuration_value = params[:configuration_item][:configuration_value]
    @configuration_item.save
    redirect_to admin_configuration_items_path
  end

end