# Client middleware that adds timestamp
module SidekiqSingle
  module Middleware
    class Client
      QUEUE_PREFIX = 'sidekiq_single'

      def call(worker_class, item, queue, redis_pool = nil)
        if queue.start_with?(QUEUE_PREFIX)
          item['sidekiq_single_enqueued_at'] = Time.now.to_f
        end

        yield
      end
    end
  end
end
