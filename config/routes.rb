Rails.application.routes.draw do

  # Carriers routes
  # TODO: need to refactor it to make it RESTful
  namespace :carrier do
    get 'session/home'
    get 'session/countries'
    get 'session/states'
    get 'session/regions'
    get 'session/createregion'
    get 'session/deleteregion'
    get 'session/insertregionzip'
    get 'session/deleteregionzip'
    get 'session/insertregionziprange'
    get 'session/deleteregionziprange'
    get 'session/insertregionstate'
    get 'session/deleteregionstate'

    get 'session/lanes'
    get 'session/createlane'
    get 'session/deletelane'
    get 'session/updatelane'
    get 'session/insertlanepricing'
    get 'session/deletelanepricing'
    get 'session/updatelanepricing'

    get 'session/getdefaultpricing'
    get 'session/updatedefaultpricing'

    get 'account/login'
    get 'account/logout'
    post 'account/login'

    post 'session/uploadpricing'
    post 'session/uploadschedulepricing'
  end

  namespace :api do
    namespace :v1 do
      resources :shipments, only: [:show]
      resources :payment_methods, only: [:create]
    end
  end

  namespace :admin do
    resources :shipments do
      member do
        get :new_charge
        post :do_new_charge
        post :complete_order
      end
    end
    resources :credit_applications
    post 'credit_events/:id', to: 'credit_applications#mark_as_paid', as: 'mark_event_as_paid'
    get "/" => 'shipments#index'
    resources :configuration_items
  end

  resources :addresses

  devise_for :users

  root 'home#index'

  get '/test_ui' => 'home#test_ui'

  get '/account' => 'account#index'

  resources :shipments, only: [:create] do
    member do
      get :track
      get :pdf
    end
    resources :shipment_parts, only: [:edit, :update]
  end

  resources :credit_applications

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end