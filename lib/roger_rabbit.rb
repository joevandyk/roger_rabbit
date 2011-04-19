require 'bunny'
require 'json'
require 'active_support/hash_with_indifferent_access'

module RogerRabbit
  def self.bunny
    if ! @bunny
      @bunny = Bunny.new
      @bunny.start
      @bunny.qos
    end
    @bunny
  end

  def self.bunny_queue queue_name
    @queues ||= {}
    @queues[queue_name] ||= bunny.queue(queue_name)
  end

  def self.consume queue_name, &block
    bunny_queue(queue_name).subscribe(:ack => true) do |msg|
      begin
        yield ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(msg[:payload]))
      rescue JSON::ParserError => e
        puts e.message
      end
    end
  end

  def self.publish queue_name, args
    args = args.to_json
    bunny_queue(queue_name).publish(args)
  end
end
