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
    if false # change to true if you want run the test case
    # Returns nil if authenticated. If not authenticated, returns
    # a URL indicating where to login.
    # We are not logged in, so call returns a URL
    authenticationPoint = ALM.isAuthenticated()
    assert_not_nil(authenticationPoint, "response from isAuthenticated means we're authenticated. that can't be.")
    
    # now we login to previously returned URL.
    loginResponse = ALM.login(authenticationPoint, ALM::Constants::USERNAME, ALM::Constants::PASSWORD)
    assert(loginResponse, "failed to login.")
    assert((ALM::RestConnector.instance.getCookieString.include? "LWSSO_COOKIE_KEY"), "login did not cause creation of Light Weight Single Sign On(LWSSO) cookie.")
    
    # proof that we are indeed logged in
    assert_nil(ALM.isAuthenticated(), "isAuthenticated returned not authenticated after login.")
    
    # and now we logout
    ALM.logout()
    
    # And now we can see that we are indeed logged out
    # because isAuthenticated once again returns a url, and not null.
    assert_not_nil(ALM.isAuthenticated(), "isAuthenticated returned authenticated after logout.")  
    end  
  end
  
  def test_GetDefectFields
    if false # change to true if you want run the test case
    loginResponse = ALM.isLoggedIn(ALM::Constants::USERNAME, ALM::Constants::PASSWORD)
    assert(loginResponse, "failed to login.")

    defectFields = ALM.getDefectFields(true)
    valueLists = ALM.getValueLists(defectFields)
    if defectFields
      defectFields.fields.each do |field|
        puts "Name = #{field.name}"
        puts "Label = #{field.label}"
        puts "Size = #{field.size}"
        puts "Type = #{field.type}"
        puts "Required = #{field.required}"
        if (field.list_id && valueLists)
          items = ValueLists.getValuesById(field.list_id, valueLists)
          items.each do |item|
            puts "Value = #{item.value}"
          end
        end
        puts "--------------------------"
      end
    
      puts defectFields.to_xml
      if valueLists
        puts valueLists.to_xml 
      end
    end  
    
    ALM.logout()
    end
  end
  
  def test_CreateDeleteDefect
    if false # change to true if you want run the test case
    loginResponse = ALM.isLoggedIn(ALM::Constants::USERNAME, ALM::Constants::PASSWORD)
    assert(loginResponse, "failed to login.")
    
    defect = Entity.new
    defect.init("defect")
    
    defectFields = ALM.getDefectFields(true)
    valueLists = ALM.getValueLists(defectFields)
    if defectFields
      defectFields.fields.each do |field|
        defectField = Field.new
        defectField.name = field.name
        type = field.type
        case type
        when "LookupList"
          if valueLists
            items = ValueLists.getValuesById(field.list_id, valueLists)
            defectField.value = items.first.value
          end
        when "Date"
          defectField.value = Time.now.strftime("%Y-%m-%d")
        when "UsersList"
          defectField.value = ALM::Constants::USERNAME
        else
          defectField.value = "0"
        end
        defect.fields.fields<<defectField
      end    
      
      puts defect.to_xml
      
      defectId = ALM.createDefect(defect)
      assert_not_nil(defectId, "fail to create defect.")

      if defectId
        deleteResponse = ALM.deleteDefect(defectId)
        assert(deleteResponse, "failed to delete defect.")
      end
    end
    
    ALM.logout()
    end
  end
  
  def test_ReadDefect
    if false # change to true if you want run the test case
    loginResponse = ALM.isLoggedIn(ALM::Constants::USERNAME, ALM::Constants::PASSWORD)
    assert(loginResponse, "failed to login.")

    defectId = '20829' # replace with real defect id  
    defect = ALM.readDefect(defectId)
    puts defect.to_xml
    
    ALM.logout()
    end
  end
  
  def test_AddDefectAttachment
    if true # change to true if you want run the test case
    loginResponse = ALM.isLoggedIn(ALM::Constants::USERNAME, ALM::Constants::PASSWORD)
    assert(loginResponse, "failed to login.")

    
    defectId = '20829' # replace with real defect id  
    if ALM::Constants::VERSIONED
      checkout = ALM.checkoutDefect(defectId, "check out comment1", -1)
      puts checkout
    else
      lock = ALM.lockDefect(defectId)
      puts lock
    end
    
    dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'test'))
    location = ALM.addDefectAttachment(defectId, dir + "/attachment.txt", "text/plain", "some random description")
    puts location
    
    if ALM::Constants::VERSIONED
      checkin = ALM.checkinDefect(defectId)
      puts checkin
    else
      unlock = ALM.unlockDefect(defectId)
      puts unlock
    end    
    
    ALM.logout()
    end
  end
  
end