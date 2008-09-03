module ApplicationHelper

  def _uncataloged_files options
    if options[:paged]
      @files_paged ||= Asset.paginate_uncataloged_files(params)
    else
      @files ||= Asset.list_uncataloged_files
    end
  end

end
