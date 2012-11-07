require 'happymapper'

class Field
  include HappyMapper
  
  element :Active, Boolean
  element :Editable, Boolean
  element :Size, Integer
  element :Filterable, Boolean
  element :Groupable, Boolean
  element :History, Boolean
  element :List-Id, Integer
  element :Type, String
  element :SupportsMultivalue, Boolean
  element :Required, Boolean
  element :System, Boolean
  element :Verify, Boolean
  element :Virtual, Boolean
end
