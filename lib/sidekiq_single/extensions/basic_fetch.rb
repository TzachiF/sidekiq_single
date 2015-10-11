module Sidekiq
  class BasicFetch
    attr_reader :single_queues
    GATE_KEEPER_LOCK = 'sidekiq_single_gate_keep_lock'
    MAX_LOCK_TIME = 10000
    class << self
      alias_method :__new__, :new  
      def new(options)
        result = __new__(options)
        single_queues = []
        queues = result.instance_variable_get('@queues')
        queues.each { |q| single_queues << q if q.include?('sidekiq_single')}
        queues_uniq = (queues - single_queues).uniq
        result.instance_variable_set(:@queues, queues_uniq)
        result.instance_variable_set(:@unique_queues, queues_uniq)
        result.instance_variable_set(:@single_queues, single_queues)
        result
      end
    end

    alias_method :__retrieve_work__, :retrieve_work

    def retrieve_work
      return __retrieve_work__ if no_single_queues?
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
              unit_of_work = UnitOfWork.new(*work_arr) 
              connection.set("#{unit_of_work.queue_name}:lock", JSON.dump(locked))
              return unit_of_work
            else
              lock_manager.unlock(locked)
              __retrieve_work__
            end 
          else
            return __retrieve_work__
          end
        else
          return __retrieve_work__
        end
      end
    end


    private

    def no_single_queues?
      single_queues.count == 0
    end

    def connection
      @connection ||= Redis.new
    end
  end
end