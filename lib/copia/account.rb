class Account
  attr_accessor :children, :balance, :currency
  attr_reader   :id, :key, :name, :type, :parent

  @@id_head = 0

  def initialize(id, key, name, description, balance, currency, type,
      parent = nil)
    @id       = id.to_i
    @key      = key
    @name     = name
    @balance  = balance
    @description = description
    @currency = Currency.find currency
    @type     = type
    @children = nil
    @parent   = parent
    @keypath  = get_keypath
  end

  def to_s
    bal = ''
    if @currency.position == 'left'
      bal << @currency.symbol
      bal << @balance
    else
      bal << @balance
      bal << @currency.symbol
    end
    "<#{@id.to_s.rjust(2, '0')}> #{@name} [#{@key}] #{bal} (#{@description})"+
      " TYPE=#{@type}"
  end

  def self.id_head
    @@id_head
  end

  # accepts raw data from rexml for a set of accounts
  # to recursively built data tree
  def self.load(raw, parent = nil)
    ar = []
    raw.each_element do |acc|
      type = nil
      if parent
        type = parent.type
      else
        type = acc.elements['type'].text
      end
      account = Account.new(
        acc.elements['id'].text,
        acc.elements['key'].text,
        acc.elements['name'].text,
        acc.elements['description'].text,
        acc.elements['balance'].text,
        acc.elements['currency'].text,
        type, parent)
      @@id_head = account.id if account.id > @@id_head
      if acc.elements['children'].count > 0
        account.children = Account.load(acc.elements['children'], account)
      end
      ar.push account
    end
    ar
  end

  def self.find(input)
    unless /[0-9]+/.match? input
      input = input.split ':'
      result = search_key(Copia.accounts, input)
    else
      result = search_index(Copia.accounts, input)
    end
    result
  end

  private

  def get_keypath
    parent = @parent
    str = @key
    while !parent.nil?
      str.prepend "#{parent.key}:"
      parent = parent.parent
    end
    str
  end

  def self.search_index(accounts, input)
    accounts.each do |acc|
      return acc if acc.id.to_i == input.to_i
      unless acc.children.nil?
        child = search_index(acc.children, input)
        return child if child
      end
    end
    return nil
  end

  def self.search_key(accounts, input)
    out = nil
    found = false
    input.each_with_index do |key, i|
      found = false
      accounts.each do |account|
        if account.key == key
          found = account
          out = found
          accounts = account.children
          accounts = [] if accounts.nil?
        end
      end
    end
    if out and !found
      nil
    else
      out
    end
  end

end
