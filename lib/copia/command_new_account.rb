class CommandNewAccount

  def initialize
    @options = {}
    @optparse = parse_options
    @options[:description] = '' unless @options.has_key? :description
  end

  def run
    if ARGV.count != 3
      @optparse
      exit
    end
    @name = ARGV[1]
    @key  = ARGV[2]
    path = ARGV[2].split ':'
    if path.count < 2
      puts "copia: error. Root node required"
      exit
    end
    doc = Copia.get_doc Copia.accounts_path
    accounts = doc.root.elements['accounts']
    parent = nil
    path.each_with_index do |key, i|
      found = false
      accounts.each do |account|
        if account.elements['key'].text == key
          found = true
          parent = account
          accounts = account.elements['children']
        end
      end
      if i == path.count-1
        if found
          puts "Final key '#{key}' already exists in #{ARGV[2]}"
          exit
        end
      else
        unless found
          puts "Parent '#{key}' not found"
          exit
        end
      end
    end
    # remaining value of $accounts is the parent node of the new account
    element = REXML::Element.new 'account'
    element.add_element 'id'
    element.add_element 'name'
    element.add_element 'key'
    element.add_element 'currency'
    element.add_element 'balance'
    element.add_element 'description'
    element.add_element 'children'
    element.elements['id'].text = Account.id_head+1
    element.elements['name'].text = @name
    element.elements['key'].text = path.last
    element.elements['currency'].text = parent.elements['currency'].text
    element.elements['balance'].text = '0.00'
    element.elements['description'].text = @options[:description]
    accounts.add_element element
    if File.write(Copia.accounts_path, doc)
      puts "copia: New account '#{@name}' created with id #{Account.id_head+1}"
    end
  end

  private 

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia new-account <name> <key> [options]\n"+
        "Arguments:\n"+
        "  name: <string>\n"+
        "  key: <parent>:<child>:<key>\n"+
        "Examples:\n"+
        "  copia na Moneybox asset:savings:moneybox\n"+
        "  copia na Mastercard liability:mastercard\n"+
        "Options:" 
      opts.on_tail("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
      opts.on("-dDESCRIPTION", "--description=DESCRIPTION",
          "What is this account for?") do |description|
        @options[:description] = description
      end
    end
    begin
      optparse.parse!
    rescue OptionParser::InvalidOption => e
      puts e
      puts ""
      puts optparse
      exit
    end
    optparse
  end

end
