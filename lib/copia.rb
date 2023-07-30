require 'optparse'
require 'bigdecimal'
require 'bigdecimal/util'
require 'fileutils'
require 'rexml/document'
require 'time'

class Copia

  VERSION  = "1.0.0"
  PREF_DIR = ".local/share/copia"
  ACC_FILE = "accounts.xml"

  def initialize
    @@accounts = []
    @@pref_path = File.join(Dir.home, PREF_DIR)
    @accounts_path = File.join(@@pref_path, ACC_FILE)
  end

  def main
    setup
    load_accounts
  end

  def accounts
    @@accounts
  end

  private

  # sets up required directories and files if not existing
  def setup
    FileUtils.mkpath @@pref_path unless Dir.exists? @@pref_path
    unless File.exists? @accounts_path
      path = File.join(__dir__, '../stub', ACC_FILE)
      res = system "cp #{path} #{@accounts_path}"
      unless res
        puts res
        exit
      end
    end
  end
  
  def load_accounts
    file = File.new @accounts_path
    doc = REXML::Document.new file
    file.close
    @@accounts = fetch_accounts doc.root.elements['accounts']
  end

  # accepts raw data from rexml for a set of accounts
  # to recursively built data tree
  def fetch_accounts(raw)
    ar = []
    raw.each_element do |acc|
      account = Account.new(
        acc.elements['id'].text,
        acc.elements['key'].text,
        acc.elements['name'].text)
      if acc.elements['children'].count > 0
        account.children = fetch_accounts acc.elements['children']
      end
      ar.push account
    end
    ar
  end


end

require 'copia/account.rb'
require 'copia/entry.rb'
require 'copia/transaction.rb'
