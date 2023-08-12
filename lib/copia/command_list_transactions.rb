class CommandListTransactions

  def initialize
    @options = {}
    @options[:accounts]  = []
    @options[:count]     = 50
    @options[:like]      = nil
    @options[:startdate] = nil
    @options[:enddate]   = nil
    @options[:sum]       = false
    @optparse            = parse_options
    @data                = []
    @start_time          = nil
    @end_time            = nil
  end

  def run
    text = ""
    @start_time = Copia.validate_datetime(@options[:startdate],
      Time.parse("1900-01-01 00:00:00 #{Time.now.zone}"))
    @end_time = Copia.validate_datetime(@options[:enddate],
      Time.parse("9999-01-01 00:00:00 #{Time.now.zone}"))
    Copia.load_transactions
    Copia.transactions.each do |transaction|
      if @options[:like]
        next if transaction.comment.nil?
        unless transaction.comment.downcase.include?(@options[:like].downcase)
          next
        end
      end
      @data.push(transaction.credit) if validate_data(transaction.credit)
      @data.push(transaction.debit) if validate_data(transaction.debit)
    end
    @data.sort_by! { |dat| dat.datetime }
    start = @data.count - @options[:count] - 1
    start = 0 if start < 0
    @data.each_with_index do |dat, i|
      text << dat.to_s << "\n" if i >= start
    end
    max_pos_key = 0
    max_bal_size = 0
    text.each_line do |line|
      max_pos_key = line.index('[') if line.index('[') > max_pos_key
      bal = line[/](.*?)[0-9]{4}-/m, 1]
      max_bal_size = bal.length if bal.length > max_bal_size
    end
    out = ""
    text.each_line do |line|
      diff = max_pos_key - line.index('[')
      padding = ""
      diff.times { |t| padding << " " }
      bal = line[/](.*?)[0-9]{4}-/m, 1]
      bal_raw = bal.clone
      unless /\.[0-9]{2}/.match?(bal)
        account = Account.find((line[/\[[a-zA-Z:]+\]/])[1..-2])
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
      line.insert(line.index(/[0-9]{4}-[0-9]{2}-[0-9]{2}/), ' ')
      out << line
    end
    max_pos_key = 0
    text = out
    text.each_line do |line|
      max_pos_key = line.index(/[0-9]{4}-[0-9]{2}-[0-9]{2}/) if line.index(/[0-9]{4}-[0-9]{2}-[0-9]{2}/) > max_pos_key
    end
    out = ""
    text.each_line do |line|
      diff = max_pos_key - line.index(/[0-9]{4}-[0-9]{2}-[0-9]{2}/)
      padding = ""
      diff.times { |t| padding << " " }
      line.insert(line.index(/[0-9]{4}-[0-9]{2}-[0-9]{2}/), padding)
      out << line
    end
    cnt = @options[:count]
    cnt = @data.count if @data.count < @options[:count]
    puts "copia: listing #{cnt} of #{@data.count} transfers"
    if start > 0
      cnt = @data.count - @options[:count]
      puts "copia: #{cnt} transfers hidden from output list"
    end
    puts out
  end

  private

  def validate_data(data) # data: Credit, Debit
    return false if Time.parse(data.datetime) < @start_time
    return false if Time.parse(data.datetime) > @end_time
    if @options[:accounts].count > 0
      @options[:accounts].each do |account|
        return true if account.id.to_i == data.account.id.to_i
      end
      return false
    end
    true
  end

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia ls [options]"
      opts.on_tail("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
      opts.on("-cCOUNT", "--count=COUNT", "Number of lines") do |c|
        if /[0-9]+/.match?(c)
          @options[:count] = c.to_i
        else
          puts "copia: -c requires an integer argument"
          exit
        end
      end
      opts.on("-S", "--sum", "Also print sums") do 
        @options[:sum] = true
      end
      opts.on("-sDATE", "--start-date=DATE",
              "Earliest transaction date") do |date|
        @options[:startdate] = date
      end
      opts.on("-eDATE", "--end-date=DATE",
              "Latest transaction date") do |date|
        @options[:enddate] = date
      end
      opts.on("-lLIKE", "--comment-like=LIKE",
              "Where comment includes arg") do |arg|
        @options[:like] = arg
      end
      opts.on("-a", "--accounts [x,y,z]", Array,
          "List transactions of requested accounts") do |list|
        unless list.nil?
          list.each do |arg|
            account = Account.find(arg)
            if account.nil?
              puts "copia: Account '#{arg}' not found"
              exit
            end
            @options[:accounts].push(account)
            if account.children
              push_children(account.children)
            end
          end
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

  def push_children(accounts)
    accounts.each do |account|
      @options[:accounts].push(account)
      if account.children
        push_children(account.children)
      end
    end
  end

end
