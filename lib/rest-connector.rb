# rest-connector.rb

require "net/http"
require "uri"

class RestConnector
    private_class_method :new
	
    attr_accessor :cookies
    attr_accessor :host
    attr_accessor :port
    attr_accessor :domain
    attr_accessor :project

    def initialize(cookies, host, port, domain, project) {
    	@cookies = cookies
    	@host = host
    	@port = port
    	@domain = domain
    	@project = project
    }
	
    def RestConnector.instance
        @@instance = new unless @@instance
        @@instance
    end
	
    def buildEntityCollectionUrl(entityType)
    	return buildUrl("qcbin/rest/domains/"
                        + domain
                        + "/projects/"
                        + project
                        + "/"
                        + entityType
                        + "s")
    end
    
    def buildUrl(patch)
    	return "http://#{host}:#{port}/#{path}
    end
    
    def httpPut(url, data, headers)
    	return doHttp("PUT", url, null, data, headers, cookies)
    end
    
    def httpPost(url, data, headers)
    	return doHttp("POST", url, null, data, headers, cookies)
    end
    
    def httpDelete(url, headers)
    	return doHttp("DELETE", url, null, null, headers, cookies)
    end
    
    def httpGet(url, queryString, headers)
    	return doHttp("GET", url, queryString, null, headers, cookies)
    end
    
    private
    
    def doHttp(type, url, queryString, data, headers, cookies)
    	if (queryString != nil && !queryString.empty)
    	    url.concat("?" + queryString)
    	end
    	
    	
    end
end