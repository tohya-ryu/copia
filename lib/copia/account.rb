class Account
  attr_reader   :id, :key, :name, :children

  @@id_head = 0

  def initialize(id, key, name)
    @id       = id.to_i
    @key      = key
    @name     = name
    @children = nil
  end

  def create(id, key, name)
  end

  # accepts raw data from rexml for a set of accounts
  # to recursively built data tree
  def self.fetch(raw)
    ar = []
    raw.each_element do |acc|
      account = Account.new(
        acc.elements['id'].text,
        acc.elements['key'].text,
        acc.elements['name'].text)
      @@id_head = account.id if account.id > @@id_head
      if acc.elements['children'].count > 0
        account.children = fetch acc.elements['children']
      end
      ar.push account
    end
    ar
  end

end
