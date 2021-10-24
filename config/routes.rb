Rails.application.routes.draw do
  root "main#rootRoute"
  get "/:amount/:from_currency/:to_currency", to: "main#calculate", amount: /[^\/]+/, from_currency: /[^\/]+/, to_currency: /[^\/]+/
  get "/rates", to: "main#rates"
  get '*path', to: 'main#badRoute'
end
