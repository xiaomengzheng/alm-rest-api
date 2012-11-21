# alm-rest-api.rb

module ALM

  # Logging in to our system is standard http login (basic authentication),
  # where one must store the returned cookies for further use.
  def self.login(loginUrl, username, password)
    response = RestConnector.instance.httpBasicAuth(loginUrl, username, password)

    return response.statusCode == '200'
  end

  def self.logout()
    # note the get operation logs us out by setting authentication cookies to:
    # LWSSO_COOKIE_KEY="" via server response header Set-Cookie
    logoutUrl = RestConnector.instance.buildUrl("qcbin/authentication-point/logout")
    response = RestConnector.instance.httpGet(logoutUrl, nil, nil)

    return response.statusCode == '200'
  end

  def self.isAuthenticated()
    isAuthenticateUrl = RestConnector.instance.buildUrl("qcbin/rest/is-authenticated") 
    response = RestConnector.instance.httpGet(isAuthenticateUrl, nil, nil)
    responseCode = response.statusCode

    # if already authenticated
    # if not authenticated - get the address where to authenticate
    # via WWW-Authenticate
    if responseCode == "200"
      ret = nil
    elsif responseCode == "401"
      authenticationHeader = response.responseHeaders["WWW-Authenticate"]
      newUrl = authenticationHeader.split("=").at(1)
      newUrl = newUrl.delete("\"")
      newUrl = newUrl + "/authenticate"
      ret = newUrl
    end

    return ret
  end
  
  # convenience method to do user login
  def self.isLoggedIn(username, password)
    authenticationPoint = isAuthenticated();
    if (authenticationPoint != nil)
        return login(authenticationPoint, username, password)
    end
    return true
  end
  
  # read all defects fields 
  def self.getDefectFields(required = false)
    defectFieldsUrl = RestConnector.instance.buildEntityCollectionUrl("customization/entities/defect/field")
    queryString = nil
    if required
      queryString = "required=true"
    end
    requestHeaders = Hash.new
    requestHeaders["Accept"] = "application/xml"
    response = RestConnector.instance.httpGet(defectFieldsUrl, queryString, requestHeaders)
    
    defectFields = nil
    if response.statusCode == '200'
      defectFields = DefectFields::Fields.parse(response.toString())
    end

    return defectFields
  end
  
  # read pre-defined defects fields values
  def self.getValueLists(defectFields = nil)
    # ALM 11.0 the url is "customization/list"
    valueListsUrl = RestConnector.instance.buildEntityCollectionUrl("customization/used-list")
    queryString = nil
    if defectFields
      defectFields.fields.each do |field|
        if field.list_id
          if queryString == nil
            queryString = "id=" + field.list_id.to_s
          else
            queryString = queryString + "," + field.list_id.to_s
          end
        end
      end
    end

    requestHeaders = Hash.new
    requestHeaders["Accept"] = "application/xml"
    response = RestConnector.instance.httpGet(valueListsUrl, queryString, requestHeaders)
    
    valueLists = nil
    if response.statusCode == '200'
      valueLists = ValueLists::Lists.parse(response.toString())
    end

    return valueLists
  end
  
  # create new defect
  def self.createDefect(defect)
    defectsUrl = RestConnector.instance.buildEntityCollectionUrl("defect")
    requestHeaders = Hash.new
    requestHeaders["Content-Type"] = "application/xml"
    requestHeaders["Accept"] = "application/xml"

    response = RestConnector.instance.httpPost(defectsUrl, defect.to_xml, requestHeaders)
    
    defectId = nil
    if response.statusCode == '201'
      defectUrl = response.responseHeaders["Location"]
      defectId = defectUrl.split('/').last
    end

    return defectId
  end
  
  # delete a defect
  def self.deleteDefect(defectId)
    defectUrl = RestConnector.instance.buildDefectUrl(defectId)
    requestHeaders = Hash.new
    requestHeaders["Accept"] = "application/xml"

    response = RestConnector.instance.httpDelete(defectUrl, requestHeaders)
 
    return response.statusCode == '200'
  end
  
  # attach a file
  def self.attachWithMultipart(defectId, filePath)
    attachmentUrl = RestConnector.instance.buildEntityCollectionUrl("attachment")
    boundary = "AaB03x"
    requestHeaders = Hash.new
    requestHeaders["Content-Type"] = "multipart/form-data, boundary=#{boundary}"

    #post_body = []
    #post_body < < "--#{boundary}rn"
    #post_body < < "Content-Disposition: form-data; name="datafile"; filename="#{File.basename(file)}"rn"
    #post_body < < "Content-Type: text/plainrn"
    #post_body < < "rn"
    #post_body < < File.read(file)
    #post_body < < "rn--#{boundary}--rn"    
    
    #Response response = RestConnector.instance.httpPost(attachmentUrl, post_body, requestHeaders)
  end

end

require 'alm-rest-api/entity'
require 'alm-rest-api/defect-fields'
require 'alm-rest-api/value-lists'
require 'alm-rest-api/constants'
require 'alm-rest-api/response'
require 'alm-rest-api/rest-connector'
