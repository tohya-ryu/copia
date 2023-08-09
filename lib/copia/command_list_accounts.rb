class CommandListAccounts

  def initialize
    @options = {}
    @options[:account] = nil
    @optparse = parse_options
    @start = true
  end

  def run
    if @options[:account]
      @start = false
    end
    text = print_accounts(Copia.accounts, 0, '')
    max_pos_key = 0
    max_bal_size = 0
    text.each_line do |line|
      max_pos_key = line.index('[') if line.index('[') > max_pos_key
      bal = line[/](.*?)\(/m, 1]
      max_bal_size = bal.length if bal.length > max_bal_size
    end
    out = ""
    text.each_line do |line|
      diff = max_pos_key - line.index('[')
      padding = ""
      diff.times { |t| padding << " " }
      bal = line[/](.*?)\(/m, 1]
      bal_raw = bal.clone
      unless /\.[0-9]{2}/.match?(bal)
        account = Account.find(line[1,2])
        if (account.currency.position == 'left')
          bal[-1] = '0'
          bal << ' '
        else
          sym = bal[-2]
          bal[-2] = '0'
          bal[-1] = sym
          bal << ' '
        end
      end
      line.insert(line.index('['), padding)
      line.gsub!(bal_raw, '')
      diff = max_bal_size - bal.size
      padding = ""
      diff.times { |d| padding << " " }
      line.insert(line.index('['), bal)
      line.insert(line.index(/.{1}[0-9]{1,}\./), padding)
      line.insert(line.index('('), ' ')
      out << line
    end
    max_pos_key = 0
    text = out
    text.each_line do |line|
      max_pos_key = line.index('(') if line.index('(') > max_pos_key
    end
    out = ""
    text.each_line do |line|
      diff = max_pos_key - line.index('(')
      padding = ""
      diff.times { |t| padding << " " }
      line.insert(line.index('('), padding)
      out << line
    end
    puts out
  end

  private

  def print_accounts(accounts, indent, str)
    flag = false
    out = str
    max_pos_key = 0
    accounts.each do |account|
      if @start == false && @options[:account].id == account.id
        @start = true
        flag   = true
      end
      str = ""
      #(indent*4).times { |n| str << " " }
      if @start
        str << account.to_s
        out << str << "\n"
      end
      out = print_accounts(account.children, indent+1, out) if account.children
      @start = false if @start && !@options[:account].nil? && flag
    end
    out
  end

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia list-accounts [options]"
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

end
