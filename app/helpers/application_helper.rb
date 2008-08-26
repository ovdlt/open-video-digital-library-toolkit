module ApplicationHelper

  def tab_for field
    render :partial => "/shared/tab", :object => field
  end

  def tab_path tab
    if @object
      send( [ tab.to_s,
              "_",
              controller.controller_name.singularize,
              "_path" ].join("").to_sym, @object )
    else
      send( [ tab.to_s,
              "_",
              controller.controller_name.singularize,
              "_path" ].join("").to_sym )
    end
  end

  def uncataloged_files options
    if options[:paged]
      @files_paged ||= Asset.paginate_uncataloged_files(params)
    else
      @files ||= Asset.list_uncataloged_files
    end
  end

end
