module CardReuse
  def all_cards_for_user(user)
    return nil unless user

    payments = Spree::Payment.joins(:order).where('spree_orders.completed_at IS NOT NULL').where('spree_orders.user_id' => user.id).order('spree_orders.created_at').where('spree_payments.source_type' => 'Spree::CreditCard').where('spree_payments.state' => 'completed')

    # TODO: Figure out how to test the implementation below
    # to more explicitly check for payment-profile information
    # payments.collect(&:source).reject(&:deleted?).reject do |src|
    #   src.gateway_payment_profile_id.nil? or src.gateway_customer_profile_id.nil?
    # end.compact.uniq

    payments.collect(&:source).reject(&:deleted?).compact.uniq
  end
end
