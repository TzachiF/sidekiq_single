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
            yield
          ensure  
            conn = Redis.new
            lockdata = conn.get("#{queue}:lock")
            lockdata = JSON.parse(lockdata)
            lockdata = lockdata.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
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
