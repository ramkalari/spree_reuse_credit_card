module OrderHelpers
  def add_to_cart(name, variant=nil)
    visit spree.root_path
    click_link name
    # in the product page
    choose variant if variant
    click_button "add-to-cart-button"
  end

  def complete_checkout_with_login(email, password)
    begin_checkout
    login_step(email, password)
    address_step
    delivery_step
    payment_step
    confirm_step
  end

  def complete_checkout_with_guest(email)
    begin_checkout
    guest_step(email)
    address_step
    delivery_step
    payment_step
    confirm_step
  end

  def begin_checkout
    visit spree.cart_path
    click_button "Checkout"
  end

  def login_step(email, password)
    within("#password-credentials") do
      fill_in "Email", :with => email
      fill_in "Password", :with => password
    end
    click_button "Login"
  end

  def guest_step(email)
    within("#guest_checkout") do
      fill_in "Email", :with => email
    end
    click_button "Continue"
  end

  def address_step
    addr = FactoryGirl.attributes_for(:address)
    within("#billing") do
      fill_in "First Name", :with => addr[:firstname]
      fill_in "Last Name", :with => addr[:lastname]
      fill_in "order_bill_address_attributes_address1", :with => addr[:address1]
      fill_in "City", :with => addr[:city]
      select FactoryGirl.attributes_for(:country)[:name], :from => "Country"
      fill_in "order_bill_address_attributes_state_name", :with => "Georgia"
      fill_in "Phone", :with => addr[:phone]
      fill_in "Zip", :with => addr[:zipcode]
    end
    within("#shipping") do
      check("Use Billing Address")
    end
    click_button "Save and Continue"
  end

  def delivery_step
    page.should have_content("Shipping Method")
    click_button "Save and Continue"
  end

  def payment_step
    page.should have_content("Payment Information")

    cc = FactoryGirl.attributes_for(:credit_card)

    within '#payment_method_1' do
      fill_in 'card_number', with: cc[:number]
      select cc[:month], from: 'payment_source_1_month'
      select cc[:year], from: 'payment_source_1_year'
      fill_in 'card_code', with: cc[:verification_value]
    end

    click_button "Save and Continue"
  end

  def confirm_step
    page.should have_content("Confirm")
    click_button "Place Order"
  end

  def complete_payment
    user = Spree.user_class.where(:email => "guy@incogni.to").first
    order = Spree::Order.where(:user_id => user.id).first

    order.payments.first.tap do |payment|
      # payment.source.update_attributes
      payment.complete!
    end
  end

  def complete_guest_payment
    Spree::Order.last.payments.first.complete!
  end

  def create_existing_subscription_for(email, product, remaining)
    FactoryGirl.create(:subscription,
      :email => email,
      :magazine => product,
      :ship_address => create(:customer_address),
      :remaining_issues => remaining
    )
  end
end
