class ChangeCreditCardDataTypeInTransactions < ActiveRecord::Migration[5.0]
  def change
    change_column :transactions, :credit_card_number, :integer, limit: 8
  end
end
