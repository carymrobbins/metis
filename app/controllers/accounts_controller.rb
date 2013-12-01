class AccountsController < ApplicationController
  before_action :signed_in_user

  def show
    @account = Account.find_by(
        customer: current_user.customer,
        id: params[:id])
    @customer_institution = CustomerInstitution.find_by(
        customer: current_user.customer,
        institution: @account.institution)
    @latest_transactions = Transaction.where(
        customer_id: current_user.customer,
        account_id: @account
    ).order('user_date desc').take(10)
  end
end
