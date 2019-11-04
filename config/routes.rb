Rails.application.routes.draw do
  get 'request/index'
  root 'request#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'fedex_consult', to: 'request#read'
  get '/reporte',to: 'request#reporte_pdf'
  post '/validar_json', to: 'request#validar_json'
end
