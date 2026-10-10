Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "account_id" => "AccountID",
    "user_id" => "UserID",
    "offer_id" => "OfferID",
    "capacity_id" => "CapacityID",
    "reservation_id" => "ReservationID",
    "payment_id" => "PaymentID",
    "order_id" => "OrderID",
    "invoice_id" => "InvoiceID",
    "arca" => "ARCA"
  )
end
