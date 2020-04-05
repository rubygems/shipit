Rails.application.routes.draw do
  get '/services/ping', to: 'ping#ping'
  get '/services/revision', to: 'ping#revision'
  mount Shipit::Engine, at: '/'
end
