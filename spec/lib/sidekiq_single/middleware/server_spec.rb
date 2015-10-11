require 'spec_helper'

describe SidekiqSingle::Middleware::Server do
  describe 'call' do
    let(:subject) { SidekiqSingle::Middleware::Server.new }
    context 'when queue is a marked as single queue' do
      let(:worker) do
        d = double('worker')
        d
      end

      let(:msg) { { 'class' => SomeWorker, 'args' => ['bob', 1, :foo => 'bar'] } }
      let(:queue) { 'sidekiq_single_queue' }

      
    end
    
    context 'when queue is a regular queue' do
      let(:queue) { 'some queue' }
      let(:msg) { { 'class' => 'SomeWorker', 'args' => ['bob', 1, :foo => 'bar'] } }
      it "should call the block" do
        foo = Proc.new { puts "aaaaaa" }
        subject.call nil, msg, queue, &foo

      end
    end

  end 
end


