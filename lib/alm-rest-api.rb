# alm-rest-api.rb

module ALM

  # Logging in to our system is standard http login (basic authentication),
  # where one must store the returned cookies for further use.
  def login(loginUrl, username, password)
    con = RestConnector.instance
    response = con.httpGet(loginUrl, null, null)
    request.basic_auth(username, password)

    return response.statusCode == '200'
  end

  def logout()
    # note the get operation logs us out by setting authentication cookies to:
    # LWSSO_COOKIE_KEY="" via server response header Set-Cookie
    con = RestConnector.instance
    response = con.httpGet(con.bildUrl("authentication-point/logout"), null, null)

    return response.statusCode == '200'
  end

  def isAuthenticated()
    con = RestConnector.instance
    response = con.httpGet(con.bildUrl("rest/is-authenticate"), null, null)
    responseCode = response.statusCode

    # if already authenticated
    # if not authenticated - get the address where to authenticate
    # via WWW-Authenticate
    if responseCode == "200"
      ret = nil
    elsif responseCode == "401"
      authenticationHeader = response["WWW-Authenticate"]
      newUrl = authenticationHeader.split("=").at(1)
      newUrl = newUrl.delete("\"")
      newUrl = newUrl + "/authenticate"
    ret = newUrl
    end

    return ret
  end

end


