require 'rubygems'
require 'test/unit'
require 'roger_rabbit'

# You should have rabbitmq installed and running.
class TestRogerRabbit < Test::Unit::TestCase

  def test_publish_consume
    queue_name = "test"
    2.times do
      RogerRabbit.publish queue_name, :joe => 'cool'
    end

    count = 0

    # RogerRabbit.consume will loop forever, so we're
    # going to break out of it with a Timeout.
    assert_raises(Timeout::Error) do
      Timeout.timeout(0.05) do
        RogerRabbit.consume queue_name do |args|
          assert_equal({ "joe" => 'cool' }, args)
          assert_equal "cool", args[:joe] # Indifferent access
          count += 1
        end
      end
    end

    assert_equal 2, count, "we should have consumed 2 messages"
  end

  def test_rpc
    queue_name = "rpc"

    Thread.new do
      RogerRabbit.rpc_listen(queue_name) do |args|
        result = {}
        args.each do |key, value|
          result[key] = "#{value}est"
        end
        result
      end
    end

    count = 0

    # With block
    RogerRabbit.rpc_message(queue_name, :joe => 'cool') do |result|
      assert_equal({"joe" => "coolest"}, result)
      count += 1
    end

    # Without block
    2.times do
      result = RogerRabbit.rpc_message(queue_name, :joe => 'cool')
      assert_equal({"joe" => "coolest"}, result)
      count += 1
    end

    sleep 0.1 # Wait for thread to finish
    assert_equal 3, count, "we should have dealt with two messages"
  end
end
