require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'redis'

describe "GameQueue" do
  before(:all) do
    $redis =  Redis.new(:host => 'localhost', :port => 6379)
    GameQueue.redis = $redis
    GameQueue.queue_name = 'skyburg_main_queue_test'
  end

  before(:each) do
    $redis.del('skyburg_main_queue_test')
  end

  it "should push something" do
    expect { GameQueue.push(:lalaee, {pizdets: true})}.to_not raise_error
  end

  context "after push" do

    before(:each) do
      @data  = {"cool" => "data", "something" => "else"}
      GameQueue.push(:event, @data)
    end

    it "should pull right data on pull" do
      GameQueue.pop.should == ["event", @data]
    end

    it "should delete everything on clean!" do
      GameQueue.push(:event, @data)
      GameQueue.clean!
      GameQueue.pop.should be_nil
    end
  end

end
