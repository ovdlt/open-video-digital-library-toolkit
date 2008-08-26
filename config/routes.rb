ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'

  map.resources :users do |users|
    users.resources :favorites
  end

  map.activate '/activate/:activation_code',
               :controller => 'users',
               :action => 'activate',
               :activation_code => nil

  map.forgot_password '/forgot_password',
                      :conditions => { :method => :get },
                      :controller => 'users',
                      :action => 'forgot_password'
    
  map.forgot_password '/forgot_password',
                      :conditions => { :method => :post },
                      :controller => 'users',
                      :action => 'reset_password'
    
  map.resources :videos, :collection => { :recent => :get,
                                          :cancel => :get,
                                          :clear => :get },
                         :member => { :download => :get,
                                      :general_information => :any,
                                      :digital_files => :any,
                                      :responsible_entities => :any,
                                      :dates => :any,
                                      :chapters => :any,
                                      :descriptors => :any,
                                      :collections => :any,
                                      :related_videos => :any,
                                      :reset => :get,
                         } do |videos|

    videos.resources :assets

  end

  map.resources :assets, :collection => { :uncataloged => :get }


  map.resources :descriptors do |descriptor|
    descriptor.resources :videos
  end
  
  map.resources :descriptor_types do |descriptor_type|
    descriptor_type.resources :videos
  end
  
  library_map = {}
  [ :general_information,
    :date_types,
    :roles,
    :descriptor_types,
    :collections,
    :digital_files,
    :rights_statements,
    :video_relation_types,
    :format_types, ].each { |k| library_map[k] = :any }

  map.resource :library,
               :controller => :library,
               :member => library_map
                        

  map.resource :session
  
  map.root :controller => 'home'
  
end
