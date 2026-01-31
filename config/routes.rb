Rails.application.routes.draw do
  get 'games/new'
  get 'games/create'
  get 'games/show'
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  get "pokemons", to: "pokemons#index"

  get "pokemons/search", to: "pokemons#search"

  resources :moves, only[:index] do

  end

  resources :pokemons, only: [:index, :show] do
  end

  # Create game session
  resources :games, only: [:new, :create, :show] do
      resources :battle

      # create a team

      resources :teams, only: [:new, :create, :show, :edit] do
        resources :selected_pokemon
      end

      # battle log

      resources :actions, only: [:new, :create] do

      end

  end

end


# Test commment
