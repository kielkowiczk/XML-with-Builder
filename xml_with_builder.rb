require "builder"
require "test/unit"

class BuilderTest < Test::Unit::TestCase
  def setup
    @xml = ''
    @doc = Builder::XmlMarkup.new :target =>@xml, :indent => 2
  end
  
  def test_create_instruct
    @doc.instruct!
    assert_equal @xml, %(<?xml version="1.0" encoding="UTF-8"?>\n)
  end
  
  def test_one_tag
    @doc.users('users-for' => 'systemV')
    assert_equal @xml, %(<users users-for="systemV"/>\n)
  end
  
  def test_nested_tag
    @doc.users('users-for' => 'systemV') { |user|
      user.user('John', 'admin' => 'no')
      user.user('Mark', :admin => 'yes')
    }
    
    assert_equal @xml, %(<users users-for="systemV">\n  <user admin="no">John</user>\n  <user admin="yes">Mark</user>\n</users>\n)
  end
  
  def test_deep_neasting_tags
    @doc.users('users-for' => 'systemV') { |user|
      user.admin do |admin|
        admin.user("name" => "John")
      end
    }
    assert_equal @xml, %(<users users-for="systemV">\n  <admin>\n    <user name="John"/>\n  </admin>\n</users>\n)
  end
  
  def test_big_xml
    should_be =<<XML
<?xml version="1.0" encoding="UTF-8"?>
<users for-system="systemV">
  <admins>
    <user>
      <name>John</name>
      <dir home="/home/john"/>
    </user>
    <user>
      <name>Mark</name>
      <dir home="/home/mark"/>
    </user>
  </admins>
  <web>
    <program>nginx</program>
  </web>
</users>
XML
    @doc.instruct!
    @doc.users('for-system' => 'systemV') { |user|
      user.admins {|admin|
        admin.user {|user|
          user.name('John')
          user.dir(:home=>'/home/john')
        }
        admin.user {|user|
          user.name('Mark')
          user.dir(:home=>'/home/mark')
        }
      }
      user.web {|web|
        web.program("nginx")
      }
    }

    assert_equal @xml, should_be
  end
end