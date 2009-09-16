class ImportMapsController < ApplicationController

  def yml
    @import_map = ImportMap.find(params[:id])
  end

  def new
    @verb = "New"
    @import_map = ImportMap.new
    render "form"
  end

  def edit
    @verb = "Edit"
    @import_map = ImportMap.find(params[:id])
    @yml = YAML::load( @import_map.yml )
    render "form"
  end

  # POST /import_maps
  # POST /import_maps.xml
  def _create
    @import_map = ImportMap.new(params[:import_map])

    respond_to do |format|
      if @import_map.save
        flash[:notice] = 'ImportMap was successfully created.'
        format.html { redirect_to(@import_map) }
        format.xml  { render :xml => @import_map, :status => :created, :location => @import_map }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @import_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @import_map = ImportMap.find(params[:id])
    if @import_map.update_attributes(params[:import_map])
      flash[:notice] = 'ImportMap was successfully updated.'
      redirect_to edit_import_map_path( @import_map )
    else
      if params[:import_map][:yml]
        render :action => "yml"
      else
        raise "hell"
        render :action => "edit"
      end
    end
  end

  # DELETE /import_maps/1
  # DELETE /import_maps/1.xml
  def _destroy
    @import_map = ImportMap.find(params[:id])
    @import_map.destroy

    respond_to do |format|
      format.html { redirect_to(import_maps_url) }
      format.xml  { head :ok }
    end
  end
end
