require 'spec_helper'

describe "PayWithCreditCards" do
  include OrderHelpers

  describe "GET /checkout/payment" do

    let(:credit_card) {
      FactoryGirl.create(:credit_card,
                         :gateway_customer_profile_id => '12345',
                         :gateway_payment_profile_id => '54321'
                        )
    }

    def reset_spree_preferences
      Spree::Preferences::Store.instance.persistence = false
      config = Rails.application.config.spree.preferences
      config.reset
      yield(config) if block_given?
    end

    before(:each) do
      reset_spree_preferences do |config|
        config.default_country_id = FactoryGirl.create(:country).id
      end

      FactoryGirl.create(:bogus_payment_method, :display_on => :front_end)
      FactoryGirl.create(:free_shipping_method)

      FactoryGirl.create(:product, :name => 'Fake Product')
      FactoryGirl.create(:user,
                         :email => 'guy@incogni.to',
                         :password => 'secret',
                         :password_confirmation => 'secret')
    end
    attr_reader :bogus_payment_method

    context "no existing cards" do
      it "does not show an existing credit card list"do
        Spree::CreditCard.destroy_all

        visit '/checkout/payment'
        page.should have_no_css('table.existing-credit-card-list tbody tr')
      end
    end

    context "existing cards" do
      before(:each) do
        add_to_cart('Fake Product')
        complete_checkout_with_login('guy@incogni.to', 'secret')
        complete_payment
      end

      it "allows an existing credit card to be chosen from list and used for a purchase" do
        add_to_cart('Fake Product')

        begin_checkout
        address_step
        delivery_step

        page.should have_xpath("//table[@class='existing-credit-card-list']/tbody/tr", :text => credit_card.last_digits)
        choose 'existing_card'

        click_button 'Save and Continue'

        page.should have_content "Ending in #{credit_card.last_digits}"
      end
    end
  end
end
