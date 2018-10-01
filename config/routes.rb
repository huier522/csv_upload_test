Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :reports do
    collection {post :import}
  end

  root 'reports#index'

end
