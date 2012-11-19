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
    assert((ALM::RestConnector.instance.getCookieString.include? "LWSSO_COOKIE_KEY"), "login did not cause creation of Light Weight Single Sign On(LWSSO) cookie.")
    
    # proof that we are indeed logged in
    assert_nil(ALM.isAuthenticated(), "isAuthenticated returned not authenticated after login.")
    
    # and now we logout
    ALM.logout()
    
    # And now we can see that we are indeed logged out
    # because isAuthenticated once again returns a url, and not null.
    assert_not_nil(ALM.isAuthenticated(), "isAuthenticated returned authenticated after logout.")    
  end
  
  def test_GetDefectFields
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
  
  def test_CreateDeleteDefect
    loginResponse = ALM.isLoggedIn(ALM::Constants::USERNAME, ALM::Constants::PASSWORD)
    assert(loginResponse, "failed to login.")
    
    defect = Entity.new("defect")
    
    defectFields = ALM.getDefectFields(true)
    valueLists = ALM.getValueLists(defectFields)
    if defectFields
      defectFields.fields.each do |field|
        defectField = Field.new
        defectField.name = field.name
        if (field.list_id && valueLists)
          items = ValueLists.getValuesById(field.list_id, valueLists)
          defectField.value = items.first.value
        else
          defectField.value = "0"
        end
        defect.fields.fields<<defectField
      end    
      
      puts defect.to_xml
      
      defectUrl = ALM.createDefect(defect)
      puts defectUrl
    
      if defectUrl
        deleteResponse = ALM.deleteDefect(defectUrl)
      end
    end
    
    ALM.logout()
  end
  
end