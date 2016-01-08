module Locksmith
  module Config
    extend ActiveSupport::Concern

    def self.config=(config_type)
      @config_type = config_type
    end

    def self.config
      @config_type.config
    end

    included do
      Locksmith::Config.config = self
    end

    module ClassMethods
      def config
        @config ||= self.new
      end

      def check_transaction_duration_over(duration, &block)
        config.max_transaction_duration = duration
        config.max_transaction_duration_checker = Proc.new {|transaction, duration| yield transaction, duration } if block_given?
      end

      def check_transaction_record_count_over(locks_count, method = nil, &block)
        config.max_transaction_record_count = locks_count
        config.max_transaction_record_count_checker = Proc.new {|transaction, locks_count| yield transaction, locks_count} if block_given?
      end

      def check_invalid_order_lock(method = nil, &block)
        config.invalid_order_lock_checker = Proc.new {|transaction, locks, invalid_order_locks| yield transaction, locks, invalid_order_locks} if block_given?
      end
    end

    attr_accessor :max_transaction_duration,
                  :max_transaction_record_count,
                  :max_transaction_duration_checker,
                  :max_transaction_record_count_checker,
                  :invalid_order_lock_checker

    def initialize
      @max_transaction_duration = nil
      @max_transaction_record_count = nil
      @max_transaction_duration_checker = nil
      @max_transaction_record_count_checker = nil
      @invalid_order_lock_checker = nil
    end
  end
end