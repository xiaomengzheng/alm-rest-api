require 'stringio'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/alm-test-api'

class TestALMRestAPI < Test::Unit::TestCase

  def setup
  end
  
 def test_login
    ret = login(url, username, password)
    assert ret
  end
end