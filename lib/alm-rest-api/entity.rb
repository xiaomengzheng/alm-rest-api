require 'happymapper'

class Field
  include HappyMapper

  tag 'Field'
  attribute :name, String, :tag => 'Name'
  element :value, String, :tag => 'Value'
end

class Fields
  include HappyMapper
  
  tag 'Fields'
  has_many :fields, Field
end

class Entity
  include HappyMapper
  
  def initialize(type)
    @type = type
    @fields = Fields.new
    @fields.fields = Array.new  
  end    
    
  tag 'Entity'
  attribute :type, String, :tag => 'Type'
  element :fields, Fields
end
