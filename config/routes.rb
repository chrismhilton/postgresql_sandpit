PostgresqlSandpit::Application.routes.draw do
  
  resources :clients do
    resources :users
  end

  resources :users
  
  root :to => 'clients#new'

end
