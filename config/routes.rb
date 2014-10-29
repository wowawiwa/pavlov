Rails.application.routes.draw do
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :cards, only: [:new, :create, :edit, :update, :index, :destroy] do
    collection{ get :export}
    collection{ get :new_batch}
    collection{ post :import}
  end
  resources :lists, only: [:new, :create, :edit, :update, :destroy]
  resources :evaluations, only: [:new, :create, :edit, :update]

  root  'main#home'

  match '/signout',   to: 'sessions#destroy',       via: 'delete'
  match '/signin',    to: 'sessions#new',           via: 'get'
  match '/signup',    to: 'main#home',              via: 'get'

  match '/help',        to: 'static_pages#help',            via: 'get'
  match '/kbshortcuts', to: 'static_pages#kbshortcuts',     via: 'get'
  match '/about',       to: 'static_pages#about',           via: 'get'
  match '/contact',     to: 'static_pages#contact',         via: 'get'

  match '/ok_guide',    to: 'users#ok_guide', via: 'get'
  
  # email confirmation
  match '/require_email_confirmation',    to: 'users#require_email_confirmation', via: 'get'
  match '/confirm_email',    to: 'users#confirm_email', via: 'get'

  # reset password request
  match '/password_reset_request',    to: 'sessions#new_password_reset_request', via: 'get'
  match '/password_reset_request',    to: 'sessions#create_password_reset_request', via: 'post'
  # reset password procedure
  match '/reset_password',    to: 'sessions#reset_password', via: 'get'
  match '/reset_password',    to: 'sessions#update_password', via: 'post'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
