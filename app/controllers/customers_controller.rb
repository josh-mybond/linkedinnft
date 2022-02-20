class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token, only: [ :webhook, :create ]

  def webhook
    endpoint_secret = 'whsec_Y98HMTMiOdOitxwzIe82fVZJOyWbxBRs';
    payload = request.body.read
    event = nil

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      # Invalid payload
      puts "⚠️  Webhook error while parsing basic request. #{e.message})"
      status 400
      return
    end
    # Check if webhook signing is configured.
    if endpoint_secret
      # Retrieve the event by verifying the signature using the raw body and secret.
      signature = request.env['HTTP_STRIPE_SIGNATURE'];
      begin
        event = Stripe::Webhook.construct_event(
          payload, signature, endpoint_secret
        )
      rescue Stripe::SignatureVerificationError
        puts "⚠️  Webhook signature verification failed. #{err.message})"
        status 400
      end
    end

    # Handle the event
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object # contains a Stripe::PaymentIntent
      puts "Payment for #{payment_intent['amount']} succeeded."
      # Then define and call a method to handle the successful payment intent.
      # handle_payment_intent_succeeded(payment_intent)
    when 'payment_method.attached'
      payment_method = event.data.object # contains a Stripe::PaymentMethod
      # Then define and call a method to handle the successful attachment of a PaymentMethod.
      # handle_payment_method_attached(payment_method)
    else
      puts "Unhandled event type: #{event.type}"
    end

    # Handle the event
    case event.type
    when 'charge.captured'
        charge = event.data.object
    when 'charge.succeeded'
        charge = event.data.object
        Customer.find_by(email: event.data.object["billing_details"]["email"])
    when 'charge.dispute.funds_reinstated'
        dispute = event.data.object
    when 'checkout.session.async_payment_failed'
        session = event.data.object
    when 'checkout.session.async_payment_succeeded'
        session = event.data.object
    # ... handle other event types
    else
        puts "Unhandled event type: #{event.type}"
    end
    status
  end

  # GET /customers or /customers.json
  def index
    @customers = Customer.all
    @customer = Customer.new
  end

  def all_customers
    @customers = Customer.all
  end
  # GET /customers/1 or /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to customer_url(@customer), notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }

      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to customer_url(@customer), notice: "Customer was successfully updated." }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to customers_url, notice: "Customer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:name, :email, :linkedin_profile_url, :linkedin_profile_image)
    end
end
