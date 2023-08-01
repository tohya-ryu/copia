Gem::Specification.new do |s|
  s.name = 'copia'
  s.version = '1.0.0'
  s.executables << 'copia'
  s.date = '2023-07-30'
  s.summary = 'A simple cli accounting tool'
  s.description = 'Copia '
  s.authors = ["ryu"]
  s.email = 'ryu@tohya.net'
  s.files = [
    "lib/copia.rb",
    "lib/copia/account.rb",
    "lib/copia/currency.rb",
    "lib/copia/entry.rb",
    "lib/copia/transaction.rb",
    "lib/copia/command_new_account.rb",
    "lib/copia/command_list_accounts.rb",
    "lib/copia/command_set_currency.rb",
    "stub/accounts.xml",
    "stub/currencies.xml"
  ]
  s.homepage = 'https://www.tohya.net/projects/misc/copia.html'
  s.license = 'GPL-3.0'
end
