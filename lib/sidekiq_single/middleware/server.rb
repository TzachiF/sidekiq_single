require 'redlock'
module SidekiqSingle
  module Middleware
    class Server
      attr_reader :queue
      QUEUE_PREFIX = 'sidekiq_single'

      def initialize(options = {})
      end

      def call(worker, msg, queue)
        @queue = queue
        if _single_queue?
          begin
            puts ">>>>> it is a single queue"
            yield
          ensure  
            conn = Redis.new
            puts ">>>>>>>>> server queue for lock #{queue}"
            lockdata = conn.get("#{queue}:lock")
            lockdata = JSON.parse(lockdata)
            lockdata = lockdata.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
            puts ">>>>>> lock data #{lockdata}"
            lock_manager = Redlock::Client.new([conn])
            lock_manager.unlock(lockdata)     
          end
        else
          yield
        end
      end

      private

      def _single_queue?
        queue.start_with?(QUEUE_PREFIX)
      end
    end
  end
end
