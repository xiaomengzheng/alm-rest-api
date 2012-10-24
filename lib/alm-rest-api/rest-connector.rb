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
    
  def buildUrl(patch)
    return 'http://#{host}:#{port}/#{path}'
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
    	  
    http = Net::HTTP.new(url)

    case type
    when "POST"
      request = Net::HTTP::Post.new("/users")
      request.set_form_data({"users[login]" => "quentin"})
      # Use nokogiri, hpricot, etc to parse response.body.
    when "GET"
      request = Net::HTTP::Get.new("/users/1")
      # As with POST, the data is in response.body.
    when "PUT"
      request = Net::HTTP::Put.new("/users/1")
      request.set_form_data({"users[login]" => "changed"})
    when "DELETE"
      request = Net::HTTP::Delete.new("/users/1")
    end
        
    cookieString = getCookieString()
    prepareHttpRequest(request, headers, data, cookieString)
        
    response = http.request(request)  
        
    res = retrieveHtmlResponse(con)
    updateCookies(res)
        
    return res  	
  end
    
  def prepareHttpRequest(con, headers, bytes, cookieString)
    contentType = nil
    if (cookieString != nil && !cookieString.empty)
       con[Cookie] = cookieString
    end
        
    if (headers != nil)
      contentType = headers.delete("Content-Type")
      headers.each{|key, value|
          con[key] = value
      }
    end
    
    if (bytes != nil)
      if (contentType != nil)
        con["Content-Type"] = contentType
          
      end
    end
  end
    
  def retrieveHtmlResponse(con)
    res = Response.new
    res.statusCode = con.code
    res.responseHeaders = con.to_hash
    res.responseData = con.form_data
    
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
    if (cookies!=nil && !cookies.empty)
      cookies.each{|key,value|
        s << key << '=' << 'value' << ';'
      }
    end
  
    return s.string
  end
end