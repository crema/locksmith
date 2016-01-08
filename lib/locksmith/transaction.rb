require 'active_record/connection_adapters/abstract/transaction'

module Locksmith
  module Transaction
    def add_record(record)
      Locksmith::TransactionLogger.add_record(record)
      super
    end
  end

  # only tracking real transactions
  module RealTransaction
    def initialize(connection, options)
      Locksmith::TransactionLogger.begin
      super
    end

    def rollback
      transaction = Locksmith::TransactionLogger.rollback
      super
      transaction.after_rollback
    end

    def commit
      transaction = Locksmith::TransactionLogger.commit
      super
      transaction.after_commit
    end
  end
end

ActiveRecord::ConnectionAdapters::Transaction.send(:prepend, Locksmith::Transaction)
ActiveRecord::ConnectionAdapters::RealTransaction.send(:prepend, Locksmith::RealTransaction)