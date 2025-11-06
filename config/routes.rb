Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :ai do
    post "products/check", to: "products#check"
  end

  namespace :api do
    namespace :v1 do
      resources :products, only: [ :create ]
    end
  end
end
