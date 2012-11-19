require 'happymapper'

module ValueLists
  
  class Item
    include HappyMapper

    tag 'Item'
    attribute :value, String, :tag => 'value'
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
    element :id, Integer, :tag => 'Id'
    has_one :items, Items
  end
  
  class Lists
    include HappyMapper

    tag 'Lists'
    has_many :lists, List    
  end
  
  def self.getValuesById(id, valueLists)
    valueLists.lists.each do |list|
      if (list.id == id)
        return list.items.items
      end
    end
  end
  
end