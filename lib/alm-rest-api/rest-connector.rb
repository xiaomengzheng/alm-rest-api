# rest-connector.rb

require 'net/http'
require 'uri'
require 'stringio'
require 'singleton'

class ALM::RestConnector
  include Singleton
  
  attr_accessor :cookies
  attr_accessor :host
  attr_accessor :port
  attr_accessor :domain
  attr_accessor :project

  def init(cookies, host, port, domain, project)
    @cookies = cookies
    @host = host
    @port = port
    @domain = domain
    @project = project
  end
	
  def buildEntityCollectionUrl(entityType)
    return buildUrl('qcbin/rest/domains/' + domain + '/projects/' + project + '/' + entityType + 's')
  end
    
  def buildUrl(path)
    return "http://#{host}:#{port}/#{path}"
  end
    
  def httpPut(url, data, headers)
    return doHttp('PUT', url, nil, data, headers, cookies)
  end
    
  def httpPost(url, data, headers)
    return doHttp('POST', url, nil, data, headers, cookies)
  end
    
  def httpDelete(url, headers)
    return doHttp('DELETE', url, nil, nil, headers, cookies)
  end
    
  def httpGet(url, queryString, headers)
    return doHttp('GET', url, queryString, nil, headers, cookies)
  end
  
  def httpBasicAuth(url, username, password)
    headers = {"username" => username, "password" => password}
    return doHttp('AUTH', url, nil, nil, headers, cookies)    
  end

  def getCookieString
    s = StringIO.new
    if (!cookies.empty?)
      cookies.each{|key,value|
        s << key << '=' << value << ';'
      }
    end
  
    return s.string
  end
      
  private
    
  def doHttp(type, url, queryString, data, headers, cookies)
    if (queryString != nil && !queryString.empty?)
    	url.concat('?' + queryString)
    end
    	  
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    case type
    when "POST"
      request = Net::HTTP::Post.new(uri.request_uri)
    when "GET"
      request = Net::HTTP::Get.new(uri.request_uri)
    when "PUT"
      request = Net::HTTP::Put.new(uri.request_uri)
    when "DELETE"
      request = Net::HTTP::Delete.new(uri.request_uri)
    when "AUTH"
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(headers["username"], headers["password"])
    end
        
    cookieString = getCookieString()
    prepareHttpRequest(request, headers, data, cookieString)
        
    response = http.request(request)  
        
    res = retrieveHtmlResponse(response)
    updateCookies(res)
        
    return res  	
  end
    
  def prepareHttpRequest(request, headers, data, cookieString)
    contentType = nil
    if (cookieString != nil && !cookieString.empty?)
       request["Cookie"] = cookieString
    end
        
    if (headers != nil)
      contentType = headers.delete("Content-Type")
      headers.each{|key, value|
          request[key] = value
      }
    end
    
    if (data != nil)
      if (contentType != nil)
        request["Content-Type"] = contentType
        request.body = data 
      end
    end
  end
    
  def retrieveHtmlResponse(response)
    res = ALM::Response.new
    res.statusCode = response.code
    res.responseHeaders = response
    res.responseData = response.body
    
    return res
  end
    
  def updateCookies(response)
    newCookies = response.responseHeaders.get_fields('Set-Cookie')
    if (newCookies != nil)
      newCookies.each{|cookie|
        c1 = cookie.split(';')[0]
        c2 = c1.split('=')
        key = c2[0]
        value = c2[1]
        cookies[key] = value
      }
    end
  end
    
end