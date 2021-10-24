Rails.application.routes.draw do
  get "/:amount/:from_currency/:to_currency", to: "main#calculate", amount: /[^\/]+/, from_currency: /[^\/]+/, to_currency: /[^\/]+/
  get '*path' => redirect('/')
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
