require 'rubygems'
require 'test/unit'
require 'roger_rabbit'

class TestRogerRabbit < Test::Unit::TestCase

  # You should have rabbitmq installed and running.
  def test_it
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
end
