require 'happymapper'

module DefectFields
  
  class Field
    include HappyMapper
  
    tag 'Field'
    attribute :physical_name, String, :tag => 'PhysicalName'
    attribute :name, String, :tag => 'Name'
    attribute :label, String, :tag => 'Label'
    element :active, Boolean, :tag => 'Active'
    element :editable, Boolean, :tag => 'Editable'
    element :size, Integer, :tag => 'Size'
    element :filterable, Boolean, :tag => 'Filterable'
    element :groupable, Boolean, :tag => 'Groupable'
    element :history, Boolean, :tag => 'History'
    element :list_id, Integer, :tag => 'List-Id'
    element :type, String, :tag => 'Type'
    element :supports_multivalue, Boolean, :tag => 'SupportsMultivalue'
    element :required, Boolean, :tag => 'Required'
    element :system, Boolean, :tag => 'System'
    element :verify, Boolean, :tag => 'Verify'
    element :virtual, Boolean, :tag => 'Virtual'
  end
  
  class Fields
    include HappyMapper

    tag 'Fields'    
    has_many :fields, Field
  end
end