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
    defectFields = Entity.load_from_xml(response.toString())
    
    return defectFields
  end
  
  # create new defect
  def createDefect(postedDefectXml)
    defectsUrl = RestConnector.instance.buildEntityCollectionUrl("defects")
    requestHeaders = Hash.new
    requestHeaders["Content-Type"] = "application/xml"
    requestHeaders["Accept"] = "application/xml"

    Response response = RestConnector.instance.httpPost(defectsUrl, postedDefectXml, requestHeaders)

    defectUrl = response.getResponseHeaders["Location"]

    return defectUrl
  end
  
  def deleteDefect(defectUrl)
    requestHeaders = Hash.new
    requestHeaders["Accept"] = "application/xml"

    Response response = RestConnector.instance.httpDelete(defectUrl, requestHeaders)
    if (response.getStatusCode() != '200')
        raise response.toString()
    end

    return response.toString()
  end

end

require 'alm-rest-api/entity'
require 'alm-rest-api/constants'
require 'alm-rest-api/response'
require 'alm-rest-api/rest-connector'
