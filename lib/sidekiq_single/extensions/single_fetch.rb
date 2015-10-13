class SingleFetch
  GATE_KEEPER_LOCK = 'sidekiq_single_gate_keep_lock'
  MAX_LOCK_TIME = 10000
  attr_reader :basic_fetch, :single_queues
  def initialize(options)
    @basic_fetch = Sidekiq::BasicFetch.new(options)
    @single_queues = []
    queues = basic_fetch.instance_variable_get('@queues')
    queues.each { |q| @single_queues << q if q.include?('sidekiq_single')}
    queues_uniq = (queues - @single_queues).uniq
    basic_fetch.instance_variable_set(:@queues, queues_uniq)
    basic_fetch.instance_variable_set(:@unique_queues, queues_uniq)
  end

  def retrieve_work
    return basic_fetch.retrieve_work if no_single_queues?
    lock_manager = Redlock::Client.new([connection])
    lock_manager.lock(GATE_KEEPER_LOCK, MAX_LOCK_TIME) do |gate_locked|
      if gate_locked
        queue = single_queues.shuffle.uniq.first
        lock_key = "#{queue}:lock" 
        locked = lock_manager.lock(lock_key, MAX_LOCK_TIME)
        if locked
          result_array = connection.lrange queue, -1, -1
          work = result_array.first
          if work
            connection.lrem queue, 1, work
            work_arr = [queue, work]
            unit_of_work = Sidekiq::BasicFetch::UnitOfWork.new(*work_arr) 
            connection.set("#{unit_of_work.queue_name}:lock", JSON.dump(locked))
            return unit_of_work
          else
            lock_manager.unlock(locked)
            basic_fetch.retrieve_work
          end 
        else
          return basic_fetch.retrieve_work
        end
      else
        return basic_fetch.retrieve_work
      end
    end
  end

  def self.bulk_requeue(inprogress, options)
    BasicFetch.bulk_requeue(inprogress, options)
  end
  def queue_name
    basic_fetch.queue_name
  end
  def requeue
    basic_fetch.requeue
  end
  def queues_cmd
    basic_fetch.queues_cmd
  end


  private

  def no_single_queues?
    single_queues.count == 0
  end

  def connection
    @connection ||= Redis.new
  end
end