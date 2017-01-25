Rails.application.routes.draw do
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      namespace :customers do
        get '/find', to: 'search#show'
        get '/find_all', to: 'search#index'
        get '/random', to: 'random#show'
      end
      resources :customers, only: [:index, :show]

      namespace :invoices do
        get '/find' => 'search#show'
        get '/find_all' => 'search#index'
        get '/random' => 'random#show'
        get ':id/transactions', to: 'transactions#index'
        get ':id/invoice_items', to: 'invoice_items#index'
        get ':id/items', to: 'items#index'
        get ':id/customer', to: 'customer#show'
        get ':id/merchant', to: 'merchant#show'
      end
      resources :invoices, only: [:index, :show]

      namespace :invoice_items do
        get '/find' => 'search#show'
        get '/find_all' => 'search#index'
        get '/random' => 'random#show'
        get ':id/invoice', to: 'invoice#show'
        get ':id/item', to: 'item#show'
      end
      resources :invoice_items, only: [:index, :show]

      namespace :items do
				get '/find' => 'search#show'
				get '/find_all' => 'search#index'
				get '/random' => 'random#show'
        get '/:id/invoice_items' => 'invoice_items#index'
        get '/:id/merchant' => 'merchant#show'
			end
      resources :items, only: [:index, :show]

      namespace :merchants do
        get '/find', to: 'search#show'
        get '/find_all', to: 'search#index'
        get '/random', to: 'random#show'
        get ':id/items', to: 'items#index'
        get '/:id/invoices', to: 'invoices#index'
      end
      resources :merchants, only: [:index, :show]

      namespace :transactions do
        get '/find', to: 'search#show'
        get '/find_all', to: 'search#index'
        get '/random', to: 'random#show'
        get '/:id/invoice', to: 'invoice#show'
      end
      resources :transactions, only: [:index, :show]
    end
  end
end
