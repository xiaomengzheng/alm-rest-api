require 'xml/mapping'

class Field; end

class Entity
  include XML::Mapping
  
  text_node :type, "Type"
  array_node :fields, "Fields", "Field", :class=>Field, :default_value=>[]
end

class Field
  include XML::Mapping

  text_node :name, "Name"
end