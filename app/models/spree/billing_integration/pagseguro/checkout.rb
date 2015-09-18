require 'pagseguro-oficial'

module Spree
  class BillingIntegration::Pagseguro::Checkout < BillingIntegration
    preference :email, :string
    preference :token, :string
    preference :environment, :string
    preference :site_url, :string

    def provider_class
      ActiveMerchant::Billing::Pagseguro
    end

    def redirect_url(order, options = {})
      response = provider.payment_url(order, options, preferences)

      if response.errors.any?
        response.errors.join("\n")
      else
        create_transaction(order, response)
        response.url
      end
    end

    def self.notification(email, token, code)
      ActiveMerchant::Billing::Pagseguro.notification(email, token, code)
    end

    def self.payment_url(code)
      ActiveMerchant::Billing::Pagseguro.checkout_payment_url(code)
    end

    private

    def create_transaction(order, response)
      PagseguroTransaction.create!(
          code: response.code,
          email: order.email,
          amount: order.total, order_id: order.id,
          status: 'pending'
      )
    end
  end
end

