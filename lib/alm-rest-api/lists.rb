require 'happymapper'

module Lists
  
  class Item
    include HappyMapper

    tag 'Item'
    attribute :value, String, :tag => 'Value'
  end
  
  class Items
    include HappyMapper

    tag 'Items'    
    has_many :items, Item    
  end
  
  class List
    include HappyMapper
    
    tag 'List'    
    element :name, String, :tag => 'Name'
    element :id, String, :tag => 'Id'
    has_one :items, Items
  end
end