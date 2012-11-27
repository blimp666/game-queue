require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'redis'

describe "GameQueue" do
  before(:all) do
    $redis =  Redis.new(:host => 'localhost', :port => 6379)
    GameQueue.redis = $redis
    GameQueue.queue_name = 'skyburg_main_queue_test'
    @data  = {"cool" => "data", "something" => "else", "started_at" => Time.now}
  end

  before(:each) do
    $redis.del('skyburg_main_queue_test')
  end

  it "should push something" do
    expect { GameQueue.push(:lalaee, {pizdets: true})}.to_not raise_error
  end

  context "after push" do

    before(:each) do
      GameQueue.push(:event, @data)
    end

    it "should pull right data on pull" do
      GameQueue.pop.should == ["event", @data, 0]
    end

    it "should delete everything on clean!" do
      GameQueue.push(:event, @data)
      GameQueue.clean!
      GameQueue.pop.should be_nil
    end
  end

  context "async_push_with_delay" do

    before(:each) { GameQueue.async_push_with_delay(1, :event, @data) }

    it "should not push nothing immediately" do
      GameQueue.pop.should be_nil
    end

    it "should push message after delay" do
      sleep 1.1
      GameQueue.pop.should == ["event", @data, 0]
    end

  end

end
