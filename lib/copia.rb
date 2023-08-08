require 'optparse'
require 'bigdecimal'
require 'bigdecimal/util'
require 'fileutils'
require 'rexml/document'
require 'securerandom'
require 'time'

class Copia

  VERSION      = '1.0.0'
  PREF_DIR     = '.local/share/copia'
  ACC_FILE     = 'accounts.xml'
  CURR_FILE    = 'currencies.xml'
  TRANSAC_FILE = 'transactions.xml'
  CONFIG_FILE  = 'config.xml'

  def initialize
    @@accounts     = []
    @@currencies   = []
    @@transactions = []
    @@pref_path    = File.join(Dir.home, PREF_DIR)
    @@config_path  = File.join(@@pref_path, CONFIG_FILE)
    set_paths @@pref_path
  end

  def main
    # prepare config
    FileUtils.mkpath @@pref_path unless Dir.exists? @@pref_path
    unless File.exists? @@config_path
      path = File.join(__dir__, '../stub', CONFIG_FILE)
      res = system "cp #{path} #{@@config_path}"
      unless res
        puts res
        exit
      end
    end
    Copia.load_config
    # use pref_path from config to run setup and load data
    @@pref_path = File.join(Dir.home, @@config.pref_dir)
    FileUtils.mkpath @@pref_path unless Dir.exists? @@pref_path
    set_paths @@pref_path
    setup
    Copia.load_currencies
    Copia.load_accounts
    case ARGV[0]
    when 'transfer', 't', 'mv'
      CommandTransfer.new.run
    when 'new-account', 'na'
      CommandNewAccount.new.run
    when 'list-accounts', 'la'
      CommandListAccounts.new.run
    when 'set-currency'
      CommandSetCurrency.new.run
    else
      puts parse_options
    end
  end

  def self.validate_datetime(datetime, default)
    if datetime
      str = ""
      if /\A[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{1,2}:[0-9]{1,2}\z/.
          match?(datetime)
        str = "#{datetime}:00 #{Time.now.zone}"
      elsif /\A[0-9]{4}-[0-9]{2}-[0-9]{2}\z/.match?(datetime)
        str = "#{datetime} 00:00:00 #{Time.now.zone}"
      else
        puts "Invalid format for date time '#{datetime}'"
        puts "Valid examples: '2000-12-31 24:45', '2000-12-31'"
        exit
      end
      begin
        out = Time.parse(str)
      rescue
        puts "Invalid format for date time '#{datetime}'"
        puts "Valid example: 2000-12-31 24:45"
        exit
      end
    else
      out = default
    end
    out
  end

  def self.validate_value(value)
    pattern1 = /\A[0-9]+.[0-9]{1,2}\z/
    pattern2 = /\A[0-9]+\z/
    pattern1.match? value or pattern2.match? value
  end

  def self.accounts
    @@accounts
  end

  def self.config
    @@config
  end

  def self.currencies
    @@currencies
  end

  def self.transactions
    @@transactions
  end

  def self.accounts_path
    @@accounts_path
  end

  def self.currencies_path
    @@currencies_path
  end

  def self.transactions_path
    @@transactions_path
  end

  def self.get_doc(filename)
    file = File.new filename
    doc = REXML::Document.new file
    file.close
    doc
  end

  def self.load_config
    doc = Copia.get_doc @@config_path
    @@config = Config.new doc.root.elements['config']
  end
  
  def self.load_accounts
    doc = Copia.get_doc @@accounts_path
    @@accounts = Account.load doc.root.elements['accounts']
  end

  def self.load_currencies
    doc = Copia.get_doc @@currencies_path
    @@currencies = Currency.load doc.root.elements['currencies']
  end

  def self.load_transactions
    doc = Copia.get_doc @@transactions_path
    @@transactions = Transaction.load doc.root.elements['transactions']
  end


  private

  def set_paths(path)
    @@accounts_path     = File.join(path, ACC_FILE)
    @@currencies_path   = File.join(path, CURR_FILE)
    @@transactions_path = File.join(path, TRANSAC_FILE)
  end

  def parse_options
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: copia <cmd> [options]\n"+
        "Commands: transfer (t,mv), new-account (na), list-accounts (la), "+
        "set-currency"
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

  # sets up required directories and files if not existing
  def setup
    unless File.exists? @@accounts_path
      path = File.join(__dir__, '../stub', ACC_FILE)
      res = system "cp #{path} #{@@accounts_path}"
      unless res
        puts res
        exit
      end
    end
    unless File.exists? @@currencies_path
      path = File.join(__dir__, '../stub', CURR_FILE)
      res = system "cp #{path} #{@@currencies_path}"
      unless res
        puts res
        exit
      end
    end
    unless File.exists? @@transactions_path
      path = File.join(__dir__, '../stub', TRANSAC_FILE)
      res = system "cp #{path} #{@@transactions_path}"
      unless res
        puts res
        exit
      end
    end
  end

end

require 'copia/account.rb'
require 'copia/config.rb'
require 'copia/credit.rb'
require 'copia/currency.rb'
require 'copia/debit.rb'
require 'copia/transaction.rb'
require 'copia/command_config.rb'
require 'copia/command_new_account.rb'
require 'copia/command_list_accounts.rb'
require 'copia/command_set_currency.rb'
require 'copia/command_transfer.rb'
