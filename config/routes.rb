Rails.application.routes.draw do
  # mount Resque::Server.new, at: '/resque'
  mount Shipit::Engine, at: '/'
end
