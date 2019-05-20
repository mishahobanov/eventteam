Rails.application.routes.draw do
  resources :projects do
    resources :rrbs_bookings
    match 'rrbs_bookings/:action', :controller => 'rrbs_bookings', :via => [:get, :post, :patch, :put]
    match 'settings/rrbs_booking/:action', :controller => 'rrbs_settings', :via => [:get, :post, :patch, :put]
  end
end