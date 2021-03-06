FactoryGirl.define do
  factory :transaction do
    credit_card_number Faker::Business.credit_card_number
    credit_card_expiration_date Faker::Number.between(100, 1250)
    result "success"

    invoice
  end
end
