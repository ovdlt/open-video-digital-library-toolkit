class FilesController < ApplicationController
  def index
    @files = Dir.new('files').entries.reject{|file| file =~ /^\./ }
  end
end
