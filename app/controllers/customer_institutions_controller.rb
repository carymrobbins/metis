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
    username = params[:username]
    password = params[:password]
    {name: name, username: username, password: password}.each do |k, v|
      if v.blank?
        @customer_institution.errors.add k, 'is required.'
      end
    end
    if @customer_institution.errors.blank?
      institution = Institution.where('lower(name) = ?', name.downcase).first
      if institution.nil?
        @customer_institution.errors.add :name, "is an invalid institution (#{name})."
      end
    else
      institution = nil
    end
    if @customer_institution.errors.blank?
      client = Aggcat.scope current_user.customer.id
      response = client.discover_and_add_accounts institution.id, username, password
      if /50\d/.match response[:status_code]
        @customer_institution.errors[:base] << "
          Institution responded with the following message:
          #{response[:result][:status][:error_info][:error_message]}"
      elsif response[:result][:challenges]
        @customer_institution.errors[:base] << '
          Your institution requires challenge questions, which this system
          does not currently support.'
      elsif not /20\d/.match response[:status_code]
        @customer_institution.errors[:base] << 'Undefined error with institution.'
        open(Rails.root.join('aggcat.error'), 'a') do |f|
          f << "#{DateTime.now} | Error with discover_and_add_accounts\n"
          f << "    Username: #{username}\n"
          f << "    Institution: #{institution.name} (#{institution.id})\n"
          f << "    Response: #{response}\n"
        end
      else
        @customer_institution.institution = institution
        @customer_institution.name = name
        if @customer_institution.save
          flash[:success] = "Successfully added #{name}!"
          return redirect_to @customer_institution
        end
      end
    end
    render 'new'
  end

  def sync
    customer_id = current_user.customer.id
    client = Aggcat.scope customer_id
    response = client.accounts
    # TODO: Just supporting banking accounts right now.  Need to update the
    # TODO: schema for credit, loan, etc. fields.
    # Data may be an Array of Hash or a single Hash.  Normalize to an Array.
    account_data = Array(response[:result][:account_list][:banking_account])
    Account.upsert account_data, translation: {:account_id => :id},
                   constants: {customer_id: customer_id}
    transaction_data = []
    # Hash of account_id, error_message
    transaction_errors = {}
    account_data.each do |row|
      account_id = row[:account_id]
      response = client.account_transactions row[:account_id],
                                             Transaction::SYNC_TIME_RANGE.ago
      if /20\d/.match response[:status_code]
        # Data may be an Array of Hash or a single Hash.  Normalize to an Array.
        transaction_data += Array(
            response.fetch_nested(:result, :transaction_list,
                                  :banking_transaction)
        # Ignore categorization for now, this doesn't work well.
        # Merge in account_id into the data.
        ).map{|t| t.except(:categorization).merge(account_id: account_id)}
      else
        transaction_errors[account_id] =
            response.fetch_nested :result, :status, :error_info, :error_message
      end
    end
    Transaction.upsert transaction_data, constants: {customer_id: customer_id}
    redirect_to action: :index
  end
end
