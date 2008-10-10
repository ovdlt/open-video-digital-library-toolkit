require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "library/show.html.haml" do

  before(:each) do
    assigns[:library] = @library = Library.find(:first)
    render "library/show"
  end

# CREATE TABLE `libraries` (
#   `id` int(11) NOT NULL auto_increment,
#   `title` varchar(50) NOT NULL,
#   `subtitle` varchar(80) default NULL,
#   `logo_url` varchar(255) default NULL,
#   `my` varchar(255) NOT NULL,
#   `collections_user_id` int(11) NOT NULL,
#   `collections_title` varchar(255) default NULL,
#   `playlists_title` varchar(255) default NULL,
#   `created_at` datetime default NULL,
#   `updated_at` datetime default NULL,
#   PRIMARY KEY  (`id`)
# ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

  it "include the library attributes" do
    attributes = @library.attributes
    reject = { "updated_at" => true, "created_at" => true, "id" => true }
    attributes.reject! { |k,v| reject[k] }
    attributes.each do |k,v|
      response.should have_tag( %(input[name='library[#{k}]'][value='#{v}']) )
    end
  end

end
