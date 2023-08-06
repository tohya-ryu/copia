class Transaction
  attr_accessor :credit, :debit
  attr_reader :id, :comment

  def initialize(id, comment)
    @id      = id
    @comment = comment
    @credit  = nil
    @debit   = nil
  end

  def self.load(transactions)
    ar = []
    transactions.each do |transaction|
      obj = Transaction.new(
        transaction.elements['id'].text,
        transaction.elements['comment'].text)
      obj.credit = Credit.new(
        obj, transaction.elements['credit'].elements['amount'].text,
        Account.find(transaction.elements['credit'].elements['account'].text),
        transaction.elements['credit'].elements['datetime'].text)
      obj.debit = Debit.new(
        obj, transaction.elements['debit'].elements['amount'].text,
        Account.find(transaction.elements['debit'].elements['account'].text),
        transaction.elements['debit'].elements['datetime'].text)
      ar.push obj
    end
    ar
  end

end
