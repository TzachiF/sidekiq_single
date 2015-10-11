# require 'celluloid'
# require 'sidekiq/fetch'
# require 'sidekiq/util'
# require 'sidekiq/actor'
# require 'sidekiq/processor'

module Sidekiq
  class BasicFetch
    attr_reader :single_queues
    ORDER = 'asc'
    SORT_BY = 'enqueued_at*'
    GATE_KEEPER_LOCK = 'sidekiq_single_gate_keep_lock'
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
        puts ">>>>>> queues #{result.instance_variable_get('@queues')}"
        puts ">>>>>> unique_queues #{result.instance_variable_get('@unique_queues')}"
        puts ">>>>>> single_queues #{result.instance_variable_get('@single_queues')}"
        result
      end
    end

    alias_method :__retrieve_work__, :retrieve_work

    def retrieve_work
      return __retrieve_work__ if no_single_queues?
      max_lock_time = 10000
      lock_manager = Redlock::Client.new([connection])
      
      lock_manager.lock(GATE_KEEPER_LOCK, max_lock_time) do |gate_locked|
        if gate_locked
          queue = single_queues.shuffle.uniq.first
          lock_key = "#{queue}:lock" 
          locked = lock_manager.lock(lock_key, max_lock_time)
          puts "locked: #{locked}:#{::Process.pid}"
          if locked
            puts ">>>>>>>>>>> in lock"
            result_array = connection.lrange queue, -1, -1
            ids = result_array.collect{|x| JSON.parse(x)['args']}
            puts ">>>>>>>>> array #{ids}"
            work = result_array.first
            puts ">>>>> work:#{work} at:#{Time.now.to_i}"
            if work
              connection.lrem queue, 1, work
              work_arr = [queue, work]
              unit_of_work = UnitOfWork.new(*work_arr) 
              puts ">>>>>>>>>>>> queue name for lock #{unit_of_work.queue_name}"
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