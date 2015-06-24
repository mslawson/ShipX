class AccountController < ApplicationController

  before_filter :authenticate_user!

  def index

    @shipments = current_user.shipments.active

  end

end