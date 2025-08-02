Rails.application.routes.draw do
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "login",
               sign_out: "logout",
               registration: "signup"
             },
             controllers: {
               sessions: "users/sessions",
               registrations: "users/registrations"
             }

  get "tools/ping" => "tools/ping#index"
  get "me" => "users/users#me"
  get "/journals", to: "journals#all"
  get "/journals/recents", to: "journals#recents"
  get "/journals/stats", to: "journals#stats"
  post "/journals/:journal_type", to: "journals#create"
  get "/journals/:journal_type/:id", to: "journals#show", as: :journal_entry
  patch "/journals/:journal_type/:id", to: "journals#update"
  put "/journals/:journal_type/:id", to: "journals#update"
  delete "/journals/:journal_type/:id", to: "journals#destroy"

  get "/admin/dashboard", to: "admin/dashboard#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
