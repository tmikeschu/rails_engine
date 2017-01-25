require 'rails_helper'

RSpec.describe 'Merchants endpoints', type: :request do
	describe "get '/api/v1/merchants/:id/items" do
		it "returns all the items for a merchant" do
			merchant = create(:merchant)
			create_list(:item, 4, merchant_id: merchant.id)

			get "/api/v1/merchants/#{merchant.id}/items"

			merchant_items = JSON.parse(response.body)

			expect(response).to be_success
			expect(merchant_items.count).to eq(4)
		end
	end
end