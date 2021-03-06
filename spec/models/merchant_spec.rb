require 'rails_helper'

RSpec.describe Merchant, type: :model do
  context 'associations' do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many :invoice_items }
    it { should have_many :transactions }
    it { should have_many :customers }
  end

  context 'business analytics' do
    describe '#revenue' do
      it 'returns total revenue' do
        merchant = create(:merchant)
        merchant.invoices << create_list(:invoice, 2)
        merchant.invoices.each do |invoice|
          invoice.transactions  << create(:transaction)
          invoice.invoice_items << create(:invoice_item, unit_price: 100)
          invoice.invoice_items << create(:invoice_item, unit_price: 150, quantity: 2)
        end

        expect(merchant.revenue).to eq(800)
      end
    end

    describe '#revenue_by_date(date)' do
      it 'returns total revenue' do
        merchant = create(:merchant)
        merchant.invoices << create_list(:invoice, 2)
        merchant.invoices.each do |invoice|
          invoice.transactions  << create(:transaction)
          invoice.invoice_items << create(:invoice_item, unit_price: 100)
          invoice.invoice_items << create(:invoice_item, unit_price: 150, quantity: 2)
        end
        new_date = merchant.invoices.first.created_at + 10.days
        merchant.invoices.first.update(created_at: new_date)
        merchant.reload

        expect(merchant.revenue_by_date(new_date)).to eq(400)
      end
    end

    describe '#revenue(date)' do
      it 'returns total revenue' do
        merchant = create(:merchant)
        merchant.invoices << create_list(:invoice, 2)
        merchant.invoices.each do |invoice|
          invoice.transactions  << create(:transaction)
          invoice.invoice_items << create(:invoice_item, unit_price: 100)
          invoice.invoice_items << create(:invoice_item, unit_price: 150, quantity: 2)
        end
        new_date = merchant.invoices.first.created_at + 10.days
        merchant.invoices.first.update(created_at: new_date)
        merchant.reload

        expect(merchant.revenue(new_date)).to eq(400)
      end
    end

    describe '.with_most_items(quantity)' do
      before do
        merchants = create_list(:merchant, 5)
        (merchants.length - 1).times do |i|
          invoices = create_list(:invoice, i + 1, merchant: merchants[i])
          invoices.each do |invoice|
            create(:transaction, invoice: invoice)
            create_list(:invoice_item, i + 1, invoice: invoice)
          end
        end
      end

      it 'returns top 3 merchants with most items sold' do
        result   = Merchant.with_most_items(3).map { |m| m.invoice_items.sum(:quantity) }
        expected = [16, 9, 4]
        expect(result).to eq(expected)
      end

      it 'returns top 4 merchants with most items sold' do
        result   = Merchant.with_most_items(4).map { |m| m.invoice_items.sum(:quantity) }
        expected = [16, 9, 4, 1]
        expect(result).to eq(expected)
      end
    end

    describe '#customers_with_pending_invoices' do
      it 'returns customers with pending invoices' do
        merchant  = create(:merchant)
        customer  = create(:customer)
        customer2 = create(:customer)
        invoice   = create(:invoice, merchant: merchant, customer: customer)
        invoice2  = create(:invoice, merchant: merchant, customer: customer2)
        invoice.transactions << create_list(:transaction, 4, result: 'failed')
        invoice2.transactions << create_list(:transaction, 4, result: 'success')

        result = merchant.customers_with_pending_invoices.map { |m| m[:id] }

        expect(result).to include(customer.id)
      end
    end

    describe '#favorite_customer' do
      it 'returns the merchants favorite customer' do
        merchant       = create(:merchant)
        top_customer   = create(:customer)
        worse_customer = create(:customer)
        invoice        = create(:invoice, merchant: merchant, customer: top_customer)
        invoice_2      = create(:invoice, merchant: merchant, customer: top_customer)
        invoice_3      = create(:invoice, merchant: merchant, customer: worse_customer)
        create(:transaction, result: 'success', invoice: invoice)
        create(:transaction, result: 'success', invoice: invoice_2)
        create(:transaction, result: 'success', invoice: invoice_3)

        expect(merchant.favorite_customer).to eq(top_customer)
      end
    end
    describe '.total_revenue(date)' do
      it 'returns total revenue of all merchants on date' do
        merchant  = create(:merchant)
        merchant2 = create(:merchant)
        merchant.invoices  << create_list(:invoice, 2)
        merchant2.invoices << create_list(:invoice, 2)
        merchant.invoices.each do |invoice|
          invoice.transactions  << create(:transaction)
          invoice.invoice_items << create(:invoice_item, unit_price: 100)
          invoice.invoice_items << create(:invoice_item, unit_price: 150, quantity: 2)
        end
        merchant2.invoices.each do |invoice|
          invoice.transactions  << create(:transaction)
          invoice.invoice_items << create(:invoice_item, unit_price: 200)
          invoice.invoice_items << create(:invoice_item, unit_price: 550, quantity: 2)
        end
        new_date = merchant.invoices.first.created_at + 10.days
        merchant.invoices.first.update(created_at: new_date)
        merchant2.invoices.last.update(created_at: new_date)
        merchant.reload
        merchant2.reload


        expect(Merchant.total_revenue(new_date)).to eq(1700)
      end
    end

    describe '.most_revenue(quantity)' do
      it 'returns top 2 merchants ranked by total revenue' do
        merchant  = create(:merchant)
        merchant2 = create(:merchant)
        merchant3 = create(:merchant)
        merchant.invoices  << create_list(:invoice, 2)
        merchant2.invoices << create_list(:invoice, 2)
        merchant3.invoices << create_list(:invoice, 2)
        merchant.invoices.each do |invoice|
          invoice.transactions  << create(:transaction)
          invoice.invoice_items << create(:invoice_item, unit_price: 100)
          invoice.invoice_items << create(:invoice_item, unit_price: 150, quantity: 2)
        end
        merchant2.invoices.each do |invoice|
          invoice.transactions  << create(:transaction)
          invoice.invoice_items << create(:invoice_item, unit_price: 200)
          invoice.invoice_items << create(:invoice_item, unit_price: 550, quantity: 2)
        end
        merchant3.invoices.each do |invoice|
          invoice.transactions  << create(:transaction)
          invoice.invoice_items << create(:invoice_item, unit_price: 200)
          invoice.invoice_items << create(:invoice_item, unit_price: 550, quantity: 2)
        end
        merchant.reload
        merchant2.reload

        result = Merchant.most_revenue(2).map { |m| m.id }
        expected = [merchant2.id, merchant3.id]

        expect(result).to eq(expected)
      end
    end
  end
end
