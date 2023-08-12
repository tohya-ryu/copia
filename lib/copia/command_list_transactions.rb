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
    out = ""
    @start_time = Copia.validate_datetime(@options[:startdate],
      Time.parse("1900-01-01 00:00:00 #{Time.now.zone}"))
    @end_time = Copia.validate_datetime(@options[:enddate],
      Time.parse("9999-01-01 00:00:00 #{Time.now.zone}"))
    Copia.load_transactions
    Copia.transactions.each do |transaction|
      if @options[:like]
        unless transaction.comment.downcase.include?(@options[:like].downcase)
          next
        end
      end
      @data.push(transaction.credit) if validate_data(transaction.credit)
      @data.push(transaction.debit) if validate_data(transaction.debit)
    end
    @data.sort_by! { |dat| dat.datetime }
    @data.each do |dat|
      out << dat.to_s << "\n"
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
            puts arg
            @options[:accounts].push(Account.find(arg))
            unless @options[:accounts][-1]
              puts "copia: Account '#{arg}' not found"
              exit
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

end
