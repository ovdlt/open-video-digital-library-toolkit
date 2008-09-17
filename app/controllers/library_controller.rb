class LibraryController < ApplicationController

  require_role [ :admin]

  def show
    @library = Library.find :first
  end

  def update

    @library = Library.find :first

    if p = params[:library]
      @library.update_attributes params[:library]
    end

    if dts = params[:descriptor_types]
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
      if missing_dts.size < 2 and missing_ds.size < 10
        missing_dts.each do |dt|
          ar = DescriptorType.find_by_id(dt) and ar.destroy
        end
        missing_ds.each do |d|
          ar = Descriptor.find_by_id(d) and ar.destroy
        end
      end
    end

    render :action => :show

  end

end
