module Locksmith
  class TransactionChecker

    attr_reader :begin_time, :end_time, :record_count

    def begin
      @begin_time = Time.zone.now
      @record_count = 0
    end

    def commit
      @end_time = Time.zone.now
    end

    def after_commit(transaction)
      duration = end_time - begin_time
      if Config.config.max_transaction_duration.present? && duration > Config.config.max_transaction_duration
        Config.config.max_transaction_duration_checker.call(transaction, duration) if Config.config.max_transaction_duration_checker.present?
      end

      if Config.config.max_transaction_record_count.present? && record_count > Config.config.max_transaction_record_count
        Config.config.max_transaction_record_count_checker.call(transaction, record_count) if Config.config.max_transaction_record_count_checker.present?
      end
    end

    def add_record(_)
      @record_count = @record_count + 1
    end
  end
end