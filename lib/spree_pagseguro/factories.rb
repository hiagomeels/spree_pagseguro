FactoryGirl.define do
  factory :pagseguro_checkout, class: Spree::BillingIntegration::Pagseguro::Checkout do
    name 'Pagseguro - Checkout'
    environment 'sandbox'
  end
end
