class AccountsController < ApplicationController
  before_action :signed_in_user

  def show
    @account = Account.find_by(
        customer: current_user.customer,
        id: params[:id])
  end
end
