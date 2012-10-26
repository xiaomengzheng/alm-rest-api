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
    assert_not_nil(authenticationPoint, "response from isAuthenticated means we're authenticated. that can't be.")
    
    # now we login to previously returned URL.
    loginResponse = ALM.login(authenticationPoint, ALM::Constants::USERNAME, ALM::Constants::PASSWORD)
    assert(loginResponse, "failed to login.")
    #assert(con.getCookieString().contains("LWSSO_COOKIE_KEY"), "login did not cause creation of Light Weight Single Sign On(LWSSO) cookie.");
  end
end