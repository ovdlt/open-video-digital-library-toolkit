class LibraryController < ApplicationController

  before_filter :login_required
  require_role [ :admin]

  before_filter :load

  def show
    render :template => "library/show"
  end

  def update

    @rollback = false
    @new = []

    Library.transaction do

      okay = true

      if l = params[:library]
        okay = false if !@library.update_attributes(l)
      end

      if pcs = params[:property_class]

        all_pc_ids = PropertyClass.find( :all, :select => "id").map &:id
        all_pc_ids = all_pc_ids - pcs.keys.map(&:to_i)

        if !all_pc_ids.empty?
          logger.warn "missing pc ids: #{all_pc_ids.inspect}"
          render :nothing => true, :status => 400
          return
        end

        pcs.each do |pc_id,pc_params|
          pc_ar = @property_classes.detect { |pc_ar| pc_ar.id == pc_id }
          if pc_ar
            logger.warn pc_params.inspect
            if pc_params["deleted"] == "deleted"
              pc_ar.destroy
            else
              pc_ar.update_attributes(pc_params)
            end
          elsif pc_id =~ /^foo_\d+$/
            # and
          elsif pc_id != "new"
            logger.warn "bad pc id: #{pc_id}"
            render :nothing => true, :status => 400
            return
          end
        end

      end

      if pts = params[:property_type]

        all_pt_ids = PropertyType.find( :all, :select => "id").map &:id
        all_pt_ids = all_pt_ids - pts.keys.map(&:to_i)
        all_pt_ids.delete PropertyType.find_by_name("Rights Statement").id

        logger.warn pts.keys.map(&:to_i).inspect

        if !all_pt_ids.empty?
          logger.warn "missing pt ids: #{all_pt_ids.inspect}"
          render :nothing => true, :status => 400
          return
        end

        # pp params[:property_type]

        pts.each do |pt_id,pt_params|
          pt_ar = @property_types.detect { |pt_ar| pt_ar.id == pt_id.to_i }
          if pt_ar
            if pt_params["deleted"] == "deleted"
              pt_ar.destroy
            else
              pt_params.delete "deleted"
              okay = false if !pt_ar.update_attributes(pt_params)
            end
          elsif pt_id =~ /^new(_[a-z]+)?_\d+$/ and pt_params["deleted"] != "deleted"
            pt_params.delete "deleted"
            @property_types << (pt = PropertyType.new pt_params)
            @new << pt
            if !pt.save
              okay = false
            end
            # pp pt.errors if !pt.errors.empty?
          elsif pt_id !~ /new(_[a-z]+)?/ and pt_params["deleted"] != "deleted"
            logger.warn "bad pt id: #{pt_id}"
            render :nothing => true, :status => 400
            return
          end
        end

      end

      if rds = params[:rights_detail]

        all_rd_ids = RightsDetail.find( :all, :select => "id").map &:id
        all_rd_ids = all_rd_ids - rds.keys.map(&:to_i)

        logger.warn rds.keys.map(&:to_i).inspect

        if !all_rd_ids.empty?
          logger.warn "missing rd ids: #{all_rd_ids.inspect}"
          render :nothing => true, :status => 400
          return
        end

        rds.each do |rd_id,rd_params|
          rd_ar = @rights_details.detect { |rd_ar| rd_ar.id == rd_id.to_i }
          if rd_ar
            if rd_params["deleted"] == "deleted"
              rd_ar.destroy
            else
              rd_params.delete "deleted"
              okay = false if !rd_ar.update_attributes(rd_params)
            end
          elsif rd_id =~ /^new_\d+$/ and rd_params["deleted"] != "deleted"
            rd_params.delete "deleted"
            @rights_details << (rd = RightsDetail.new rd_params)
            @new << rd
            if !rd.save
              okay = false
            end
            # pp rd.errors if !rd.errors.empty?
          elsif rd_id != "new" and rd_params["deleted"] != "deleted"
            logger.warn "bad rd id: #{rd_id}"
            render :nothing => true, :status => 400
            return
          end
        end

      end

      if dvs = params[:descriptor_value]

        all_dv_ids = DescriptorValue.find( :all, :select => "id").map &:id
        all_dv_ids = all_dv_ids - dvs.keys.map(&:to_i)

        logger.warn dvs.keys.map(&:to_i).inspect

        if !all_dv_ids.empty?
          logger.warn "missing dv ids: #{all_dv_ids.inspect}"
          render :nothing => true, :status => 400
          return
        end

        dvs.each do |dv_id,dv_params|
          dv_ar = @descriptor_values.detect { |dv_ar| dv_ar.id == dv_id.to_i }
          if dv_ar
            if dv_params["deleted"] == "deleted"
              dv_ar.destroy
            else
              dv_params.delete "deleted"
              okay = false if !dv_ar.update_attributes(dv_params)
            end
          elsif dv_id =~ /^new(_[a-z]+)?_\d+$/ and dv_params["deleted"] != "deleted"
            dv_params.delete "deleted"
            @descriptor_values << (dv = DescriptorValue.new dv_params)
            @new << dv
            if !dv.save
              okay = false
            end
            # pp dv.errors if !dv.errors.empty?
          elsif dv_id !~ /new(_[a-z]+)?/ and dv_params["deleted"] != "deleted"
            logger.warn "bad dv id: #{dv_id}"
            render :nothing => true, :status => 400
            return
          end
        end

      end

      if false and dts = params[:descriptor_types]
        missing_dts = ( DescriptorType.find :all, :select => "id" ).map &:id
        missing_ds = ( Descriptor.find :all, :select => "id" ).map &:id
        dts.each do |dt_id,param|
          if dt_id == "new_dt"
          elsif dt_id =~ /new_dt_\d+/
            p "new dt", param
            dt = DescriptorType.new
            param.each do |k,v|
              if k == "descriptors"
                v.each do |d_id,d_param|
                  if d_id == "new_d"
                  elsif d_id =~ /new_d_\d+/
                    d = Descriptor.new
                    d_param.each do |k,v|
                      d[k] = v
                    end
                    dt.descriptors << d
                  end
                end
              else
                dt[k] = v
              end
            end
            p "bs",dt
            dt.save!
          else
            dt = DescriptorType.find dt_id
            if dt
              missing_dts.delete dt.id
              param.each do |k,v|
                if k == "descriptors"
                  v.each do |d_id,d_param|
                    if d_id == "new_d"
                    elsif d_id =~ /new_d_\d+/
                      d = Descriptor.new
                      d_param.each do |k,v|
                        d[k] = v
                      end
                      dt.descriptors << d
                    else
                      d = Descriptor.find d_id
                      missing_ds.delete d.id
                      if d
                        d_param.each do |k,v|
                          d[k] = v
                        end
                      end
                      d.save
                    end
                  end
                else
                  dt[k] = v
                end
              end
            end
            dt.save
          end
        end
        if false and missing_dts.size < 2 and missing_ds.size < 10
          missing_dts.each do |dt|
            ar = DescriptorType.find_by_id(dt) and ar.destroy
          end
          missing_ds.each do |d|
            ar = Descriptor.find_by_id(d) and ar.destroy
          end
        end
      end

      if !okay
        @rollback = true
        flash[:error] = "Errors exist; could not update"
        render :action => :show
        raise ActiveRecord::Rollback
      else
        redirect_to library_path
      end

    end

  end

  private

  def parameters

    reject = {
      "updated_at" => true,
      "created_at" => true,
      "id" => true,
    }

    reject_block = lambda { |k,v| reject.has_key? k }

    l = Library.find :first

    params = {}

    params["library"] = l.attributes.reject &reject_block

    property_classes = params["property_class"] = {}
    
    PropertyClass.find(:all).each do |pc|
      property_classes[pc.id] = pc.attributes.reject &reject_block
    end

    property_types = params["property_type"] = {}
    PropertyType.find(:all).each do |pt|
      property_types[pt.id] = pt.attributes.reject &reject_block
    end

    descriptor_values = params["descriptor_value"] = {}
    DescriptorValue.find(:all).each do |dv|
      descriptor_values[dv.id] = dv.attributes.reject &reject_block
    end

    rights_details = params["rights_detail"] = {}
    RightsDetail.find(:all).each do |rd|
      rights_details[rd.id] = rd.attributes.reject &reject_block
    end

    params

  end

  def load
    @library = Library.find :first
    @property_classes = PropertyClass.find :all
    @property_types = PropertyType.find :all
    @descriptor_values = DescriptorValue.find :all
    @rights_details = RightsDetail.find :all
  end

end
