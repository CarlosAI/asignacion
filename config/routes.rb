Rails.application.routes.draw do
  get 'request/index'
  root 'request#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'fedex_consult', to: 'request#read'
end
