require 'pagseguro-oficial'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class Pagseguro < Gateway

      def payment_url(order, options, preferences)
        ::PagSeguro.environment = preferences[:environment]

        redirect_url = "#{preferences[:site_url]}/pagseguro/callback?order=#{options[:order_id]}"
        notification_url = "#{preferences[:site_url]}/pagseguro/notify"

        payment = ::PagSeguro::PaymentRequest.new(email: preferences[:email], token: preferences[:token])

        payment.reference = options[:order_id]
        payment.notification_url = notification_url
        payment.redirect_url = redirect_url

        order.line_items.each do |product|
          payment.items << {
              id: product.id,
              description: product.name,
              amount: product.price,
              weight: (product.variant.weight * 1000).to_i
          }
        end

        payment.sender = {
            name: [order.bill_address.firstname, order.bill_address.lastname].join(' '),
            email: order.email,
        }

        payment.shipping = {
            type_name: :not_specified,
            cost: order.shipment_total,
            address: {
                street: order.bill_address.address1,
                complement: order.bill_address.address2,
                district: order.bill_address.district,
                city: order.bill_address.city,
                state: order.bill_address.state.abbr,
                postal_code: order.bill_address.zipcode
            }
        }

       payment.register

      end

      def self.notification(email, token, notification_code)
        PagSeguro::Transaction.find_by_notification_code(params[:notification_code])
      end

      def self.checkout_payment_url(code)
        ::PagSeguro.site_url("v2/checkout/payment.html?code=#{code}")
      end

    end
  end
end
