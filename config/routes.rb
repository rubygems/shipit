Rails.application.routes.draw do
  match "/ping" => lambda{ |env| [200, {'Content-Type' => 'text/plain'}, ['PONG']] }

  mount Resque::Server.new, at: '/resque'
  mount Shipit::Engine, at: '/'
end
