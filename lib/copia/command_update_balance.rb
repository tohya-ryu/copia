class CommandUpdateBalance

  def initialize
    @options = {}
    @options[:account] = nil
    @optparse = parse_options
    @doc = Copia.get_doc Copia.accounts_path
    @parent_balances = {}
  end

  def run
    if ARGV.count > 1
      puts @optparse
      exit
    end
    update_accounts(Copia.accounts)
    if File.write(Copia.accounts_path, @doc)
      puts "copia: Balances updated"
    end
  end

  private

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia update-balance [options]\n"+
        "Examples:\n"+
        "  copia update-balance -a a:my_account\n"+
        "Options:"
      opts.on_tail("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
      opts.on("-aACCOUNT", "--account=ACCOUNT",
          "Update balances for {account}") do |input|
        @options[:account] = Account.find(input)
        unless @options[:account]
          puts "copia: Account '#{input}' not found"
          exit
        end
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

  def update_accounts(accounts)
    accounts.each do |account|
      if account.children
        update_accounts(account.children)
      else
        # fetch balances
        balance = account.get_balance_from_db
        # update account
        update_account(@doc.root.elements['accounts'], account, balance)
        # update parents
        while account.parent
          pbalance = nil
          if @parent_balances.has_key?("#{account.parent.id}")
            pbalance = @parent_balances["#{account.parent.id}"]
          else
            pbalance = account.parent.get_balance_from_db
          end
          sum = BigDecimal("0.00")
          sum = BigDecimal(balance) + BigDecimal(pbalance)
          @parent_balances["#{account.parent.id}"] = sum.clone
          update_account(@doc.root.elements['accounts'], account.parent,
            sum.to_digits)
          account = account.parent
        end
      end
    end
  end

  def update_account(raw_accounts, account, balance)
    raw_accounts.each do |raw|
      if raw.elements['id'].text.to_i == account.id.to_i
        raw.elements['balance'].text = balance
      elsif raw.elements['children'].count > 0
        update_account(raw.elements['children'], account, balance)
      end
    end
  end

end
