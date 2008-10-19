require File.expand_path(File.dirname(__FILE__) + '/../spec_helper_trans')

describe LibraryController do

  before(:each) do
    login_as_admin
    @params = {}
    @params["property_type"] =
      controller.send(:parameters)["property_type"]
    @pt_id = @params["property_type"].keys[4]
    @pt = @params["property_type"][@pt_id]
  end

  describe "without transactional fixtures" do

    it "should give an error on duplicated names and not do anything" do

      PropertyType.find_by_name("foo").should be_nil

      new = @params["property_type"]["new_1123"] = {}
      new["name"] = "foo"
      new["property_class_id"] = 1
      new["deleted"] = nil

      new = @params["property_type"]["new_1124"] = {}
      new["name"] = "foo"
      new["property_class_id"] = 1
      new["deleted"] = nil

      post :update, @params
      response.should be_success

      PropertyType.find_by_name("foo").should be_nil
    end

  end

end
