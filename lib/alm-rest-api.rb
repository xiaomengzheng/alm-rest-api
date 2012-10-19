# Authenticate.rb

require "net/http"
require "uri"

BASE_URI = 'http://10.0.0.8/qcbin/'

# Logging in to our system is standard http login (basic authentication),
# where one must store the returned cookies for further use.
def login(loginUrl, username, password)
    response = nil

    uri = URI.parse(loginUrl) 
           
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(username, password)
    response = http.request(request)
        
    return response.code == '200'
end

def logout()
    logoutUrl = "authentication-point/logout"
    response = nil
    ret = nil
    
    # note the get operation logs us out by setting authentication cookies to:
    # LWSSO_COOKIE_KEY="" via server response header Set-Cookie
    uri = URI.parse(BASE_URI + logoutUrl)        
    response = Net::HTTP.get_response(uri)
    
    return ret
end

def isAuthenticated()

    isAuthenticateUrl = "rest/is-authenticated"
    response = nil
    ret = nil
                   
    uri = URI.parse(BASE_URI + isAuthenticateUrl)        
    response = Net::HTTP.get_response(uri)
    responseCode = response.code
    
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

# if we're authenticated we'll get a null, otherwise a URL where we should login at (we're not logged in, so we'll get a URL).
authenticationPoint = isAuthenticated()
if authenticationPoint != nil
    puts "response from isAuthenticated means we're authenticated. that can't be."
end

# now we login to previously returned URL.
loginResponse = login(authenticationPoint, "sa", "C71a04t23")
if loginResponse
    puts "login did not cause creation of Light Weight Single Sign On(LWSSO) cookie."
else
    puts "failed to login."
end

# proof that we are indeed logged in
if isAuthenticated() == nil
    puts "isAuthenticated returned authenticated after login."
end

#and now we logout
logout();

# And now we can see that we are indeed logged out
# because isAuthenticated once again returns a url, and not null.
if isAuthenticated() != nil
    puts "isAuthenticated returned not authenticated after logout."
end


