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
    
  private
    
  def doHttp(type, url, queryString, data, headers, cookies)
    if (queryString != nil && !queryString.empty)
    	url.concat('?' + queryString)
    end
    	  
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    case type
    when "POST"
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({"users[login]" => "quentin"})
      # Use nokogiri, hpricot, etc to parse response.body.
    when "GET"
      request = Net::HTTP::Get.new(uri.request_uri)
    when "PUT"
      request = Net::HTTP::Put.new(uri.request_uri)
      request.set_form_data({"users[login]" => "changed"})
    when "DELETE"
      request = Net::HTTP::Delete.new(uri.request_uri)
    end
        
    cookieString = getCookieString()
    prepareHttpRequest(request, headers, data, cookieString)
        
    response = http.request(request)  
        
    #res = retrieveHtmlResponse(response)
    #updateCookies(res)
        
    return response  	
  end
    
  def prepareHttpRequest(request, headers, bytes, cookieString)
    contentType = nil
    if (cookieString != nil && !cookieString.empty?)
       request[Cookie] = cookieString
    end
        
    if (headers != nil)
      contentType = headers.delete("Content-Type")
      headers.each{|key, value|
          request[key] = value
      }
    end
    
    if (bytes != nil)
      if (contentType != nil)
        request["Content-Type"] = contentType
          
      end
    end
  end
    
  def retrieveHtmlResponse(response)
    res = Response.new
    res.statusCode = response.code
    res.responseHeaders = response.to_hash
    res.responseData = response.form_data
    
    return res
  end
    
  def updateCookies(response)
    newCookies = response.responsHeaders['Set-Cookie']
    if (newCookies != nil)
      newCookies.each{|key, value|
        
      }
    end
  end
    
  def getCookieString
    s = StringIO.new
    if (!cookies.empty?)
      cookies.each{|key,value|
        s << key << '=' << 'value' << ';'
      }
    end
  
    return s.string
  end
end