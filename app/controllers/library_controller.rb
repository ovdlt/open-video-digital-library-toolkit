class LibraryController < ApplicationController

  before_filter :handle_category,
                :only => [ :general_information,
                           :date_types,
                           :roles,
                           :descriptor_types,
                           :collections,
                           :digital_files,
                           :rights_statements,
                           :video_relation_types,
                           :format_types, ]
  
  private

  def handle_category
    @library = Library.find :first
    case request.method
    when :get;
      render :layout => false
    when :put;
      params[:library].each do |k,v|
        @library[k] = v
      end
      @library.save
      redirect_to library_path
      # render :nothing => true
    else
      render_bad_request
    end
  end

end
