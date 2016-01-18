# Locksmith

ActiveRecord transaction checker

* check max duration
* check max record lock count
* check invalid s-lock, x-lock order
 
# Usage

add config/inializers/locksmith.rb

```ruby
class LocksmithConfig
  include Locksmith::Config

  check_transaction_duration_over 10.seconds do |transaction, duration|
    # blah blah    
  end

  check_transaction_record_count_over 100 do |transaction, locks_count|
     # blah blah    
  end

  check_invalid_order_lock do |transaction, locks, invalid_order_locks|
     # blah blah    
  end

end
```
