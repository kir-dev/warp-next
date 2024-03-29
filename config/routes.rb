Rails.application.routes.draw do
  resources :albums do
    member do
      delete :delete_image
      post :add_image
      get :image
    end

    collection do
      get :myalbums
    end
  end

  resources :users, except: [:index, :new, :create] do
    collection do
      get :adminpage
    end
  end

  resources :circles do
    member do
      get :details
    end
  end
  resources :memberships do
    member do
      post :accept
      post :demote
      post :promote
    end
  end

  get '/images/:id', to: 'album_image#show', as: :album_image

  get '/login', to: 'sessions#new', as: :login
  get '/logout', to: 'sessions#destroy', as: :logout
  get '/auth/oauth/callback', to: 'sessions#create'
  root 'home#home'
end
