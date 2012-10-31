class ALM::Response
  attr_accessor :responseHeaders
  attr_accessor :responseData
  attr_accessor :failure
  attr_accessor :statusCode
  
  def toString()
    return responseData
  end

  def toString()
    return responseData.body
  end
end