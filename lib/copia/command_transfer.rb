class CommandTransfer

  def initialize
    @options = {}
    @options[:datetime] = nil
    @options[:comment]  = ''
    @optparse = parse_options
  end

  def run
    if ARGV.count != 4
      puts @optparse
      exit
    end
    from   = Account.find ARGV[2]
    to     = Account.find ARGV[3]
    amount = ARGV[1]
    # validate input
    datetime = Copia.validate_datetime(@options[:datetime], Time.now)
    if from.nil?
      puts "copia: Account '#{from}' not found"
      exit
    end
    if to.nil?
      puts "copia: Account '#{to}' not found"
      exit
    end
    unless Copia.validate_value amount
      puts "copia: Invalid amount '#{amount}'. Available formats: n.dd | n.d | n"
      exit
    end
    # get fresh id
    Copia.load_transactions
    id = nil
    loop do 
      id = SecureRandom.uuid
      found = false
      Copia.transactions.each do |transaction|
        if transaction.id == id
          found = true
          break
        end
      end
      break unless found
    end 
    # save transaction
    transaction = Transaction.new(id, @options[:comment])
    transaction.credit = Credit.new(transaction, amount, from, datetime)
    transaction.debit  = Debit.new(transaction, amount, to, datetime)
    doc = Copia.get_doc Copia.transactions_path
    transaction_element = REXML::Element.new 'transaction'
    credit_element      = REXML::Element.new 'credit'
    debit_element       = REXML::Element.new 'debit'
    transaction_element.add_element 'id'
    transaction_element.add_element 'comment'
    transaction_element.elements['id'].text = transaction.id
    transaction_element.elements['comment'].text = transaction.comment
    credit_element.add_element 'amount'
    credit_element.add_element 'account'
    credit_element.add_element 'datetime'
    credit_element.elements['amount'].text = transaction.credit.amount
    credit_element.elements['account'].text = transaction.credit.account.id
    credit_element.elements['datetime'].text = transaction.credit.datetime
    debit_element.add_element 'amount'
    debit_element.add_element 'account'
    debit_element.add_element 'datetime'
    debit_element.elements['amount'].text = transaction.debit.amount
    debit_element.elements['account'].text = transaction.debit.account.id
    debit_element.elements['datetime'].text = transaction.debit.datetime
    transaction_element.add_element credit_element
    transaction_element.add_element debit_element
    doc.root.elements['transactions'].add_element transaction_element
    if File.write(Copia.transactions_path, doc)
      puts "copia: New transaction created with id #{transaction.id}"
    end
    # update balances (credit)
    balance = BigDecimal(transaction.credit.account.balance)
    balance = balance + transaction.credit.value
    transaction.credit.account.balance = balance.to_digits
    parent = transaction.credit.account.parent
    while parent
      balance = BigDecimal(parent.balance)
      balance = balance + transaction.credit.value
      parent.balance = balance.to_digits
      parent = parent.parent
    end
    # update balances (debit)
    balance = BigDecimal(transaction.debit.account.balance)
    balance = balance + transaction.debit.value
    transaction.debit.account.balance = balance.to_digits
    parent = transaction.debit.account.parent
    while parent
      balance = BigDecimal(parent.balance)
      balance = balance + transaction.debit.value
      parent.balance = balance.to_digits
      parent = parent.parent
    end
    doc = Copia.get_doc Copia.accounts_path
    set_balances doc.root.elements['accounts']
    if File.write(Copia.accounts_path, doc)
      puts "copia: Balances updated"
    end
  end
  
  private 

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia transfer <value> <from> <to> [options]\n"+
        "Examples:\n"+
        "  copia transfer 70.00 a:giro e:entertainment\n"+
        "  copia mv 2000.00 i:salary a:giro\n"+
        "  copia t  -200.00 5 6\n"+
        "Options:" 
      opts.on_tail("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
      opts.on("-dDATETIME", "--datetime=DATETIME",
          "yyyy-mm-dd [hh:mm]") do |datetime|
        @options[:datetime] = datetime
      end
      opts.on("-cCOMMENT", "--comment=COMMENT", "Comment") do |comment|
        @options[:comment] = comment
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

  def set_balances(raw_accounts)
    raw_accounts.each do |racc|
      acc = Account.find racc.elements['id'].text
      racc.elements['balance'].text = acc.balance
      if racc.elements['children'].count > 0
        set_balances racc.elements['children']
      end
    end
  end

end
