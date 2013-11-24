class CustomerInstitutionsController < ApplicationController
  before_action :signed_in_user

  def index
    @customer_institution = current_user.customer.try(:customer_institutions) || []
  end

  def show
    @customer_institution = CustomerInstitution.find_by(
        id: params[:id],
        customer: current_user.customer)
    @accounts = Account.where(
        'customer_id = ? and institution_id = ?',
        current_user.customer.try(:id),
        @customer_institution.institution_id)
  end

  def new
    @customer_institution = CustomerInstitution.new customer: current_user.customer
  end

  def create
    @customer_institution = CustomerInstitution.new customer: current_user.customer
    name = params[:customer_institution][:name]
    institution = Institution.where('lower(name) = ?', name.downcase).first
    if institution
      @customer_institution.institution = institution
      @customer_institution.name = name
      if @customer_institution.save
        return redirect_to @customer_institution
      end
    else
      @customer_institution.errors.add :name, "is an invalid institution (#{name})."
    end
    render 'new'
  end

  def sync
    @customer_institution = CustomerInstitution.find_by(
        id: params[:id],
        customer: current_user.customer)
    # TODO: Send to a form that prompts for username and password for bank.
    # TODO: This will then do a client.discover_and_add_accounts.
  end
end
