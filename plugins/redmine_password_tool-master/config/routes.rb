=begin
match 'projects/:id/password_tool', :to => 'password_instances#index', :via => [:get]
match 'projects/:id/password_tool/new', :to => 'password_instances#new', :via => [:get]
match 'projects/:id/password_tool', :to => 'password_instances#create', :via => [:post]

match 'projects/:id/password_tool/:password_instance_id', :to => 'password_instances#destroy', :via => [:delete]
match 'projects/:id/password_tool/:password_instance_id', :to => 'password_instances#edit', :via => [:put]
match 'projects/:id/password_tool/:password_instance_id', :to => 'password_instances#update', :via => [:post]

match 'projects/:id/password_tool/:password_instance_id', :to => 'password_instances#show', :via => [:get]
=end


# Instances
resources :projects do
  resources :password_instances, shallow: true
end
match 'password_instances/:id/data_schema', :to => 'password_instances#data_schema', :via => [:get]


resources :password_templates, :only => [:index,:show]
get 'password_templates/:id/form', :to => 'password_templates#form'
