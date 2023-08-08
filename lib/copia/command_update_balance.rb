class CommandUpdateBalance

  def initialize
    @options = {}
    @options[:account] = nil
    @optparse = parse_options
    @doc = Copia.get_doc Copia.accounts_path
  end

  def run
    if ARGV.count > 1
      puts @optparse
      exit
    end
    update_accounts(Copia.accounts)
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
        # update account
        # update parents
      end
    end
  end

end
