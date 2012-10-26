require 'stringio'
require 'test/unit'
require 'alm-rest-api'

class TestALMRestAPI < Test::Unit::TestCase

  def setup
    ALM::RestConnector.instance.init(Hash.new, 
      ALM::Constants::HOST, 
      ALM::Constants::PORT, 
      ALM::Constants::DOMAIN, 
      ALM::Constants::PROJECT)
  end
  
  def test_AuthenticateLoginLogout
    # Returns nil if authenticated. If not authenticated, returns
    # a URL indicating where to login.
    # We are not logged in, so call returns a URL
    authenticationPoint = ALM.isAuthenticated()
    assert_not_nil(authenticationPoint, "We are logged in.")
    
    #ret = login(authenticationPoint, Constants.USERNAME, Constants.PASSWORD)
  end
end