ActionController::Routing::Routes.draw do |map|

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'

  map.resources :users

  map.resources :saved_queries
  map.resources :favorites

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
                                      :reset => :get,
                         } do |videos|
    videos.resources :assets
  end

  map.videos_home "/videos/home/:style", :controller => "videos",
                                         :action => "home"

  map.resources :assets, :collection => { :uncataloged => :any }

  map.resource :library, :controller => :library

  map.resource :my, :controller => :my,
                    :member => { :home => :get,
                                 :favorites => :get,
                                 :my_account => :get,
                                 :saved_searches => :get,
                                 :downloaded_videos => :get,
                                 :playlists => :get,
                                 :password => :put,
                               }

  map.resources :collections,
                :collection => { :collections => :get,
                                 :playlists => :get,
                               } do |collections|
    collections.resources :bookmarks
  end

  map.resources :sessions

  map.connect 'home/:action', :controller => "home"
  
  map.connect "tagging/:action", :controller => "tagging"

  map.root :controller => 'home'
  
end
