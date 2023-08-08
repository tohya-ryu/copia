class CommandListAccounts

  def initialize
    @optparse = parse_options
  end

  def run
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
      unless /\.00/.match?(bal)
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
      line.gsub!(bal, '')
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
    out = str
    max_pos_key = 0
    accounts.each do |account|
      str = ""
      #(indent*4).times { |n| str << " " }
      str << account.to_s
      out << str << "\n"
      out = print_accounts(account.children, indent+1, out) if account.children
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
