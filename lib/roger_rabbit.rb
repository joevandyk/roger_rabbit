require 'bunny'
require 'json'
require 'active_support/hash_with_indifferent_access'

# WARNING: I don't understand yet how rabbitmq works
# This probably doesn't work at all.
module RogerRabbit
  def self.bunny
    if ! Thread.current[:bunny]
      Thread.current[:bunny] = Bunny.new
      Thread.current[:bunny].start
      Thread.current[:bunny].qos
    end
    Thread.current[:bunny]
  end

  def self.bunny_queue queue_name
    Thread.current[:queues] = {}
    Thread.current[:queues][:queue_name] ||= bunny.queue(queue_name)
  end

  # WARNING: I don't understand yet how RPC works in
  # rabbitmq.  Need to do more research. This probably
  # doesn't really work.
  def self.rpc_listen queue_name, &block
    # Exchange definition
    bunny.exchange('reply', :type => :direct)
    bunny.exchange('out',   :type => :direct)

    bunny.queue('rpc').bind('out')

    # Publish!
    bunny.queue('rpc').subscribe(:header => true) do |msg|
      result = block.call(deserialize(msg))
      bunny.exchange('reply').publish(serialize(result), :key => msg[:header].reply_to)
    end
  end

  # WARNING: I don't understand yet how RPC works in
  # rabbitmq.  Need to do more research. This probably
  # doesn't really work.
  def self.rpc_message queue_name, hash, &block
    # Exchange definition
    bunny.exchange('reply', :type => :direct)
    bunny.exchange('out',   :type => :direct)

    # Create the temporary queue and bind it
    reply = bunny.queue
    reply.bind('reply', :key => reply.name)

    # Publish!
    bunny.exchange('out').publish(serialize(hash), :reply_to => reply.name)

    reply.subscribe do |msg|
      msg = deserialize(msg)
      yield msg if block_given?
      reply.unsubscribe
      return msg
    end
  end

  def self.consume queue_name, &block
    bunny_queue(queue_name).subscribe(:ack => true) do |msg|
      begin
        yield deserialize(msg)
      rescue JSON::ParserError => e
        puts e.message
      end
    end
  end

  def self.publish queue_name, hash
    bunny_queue(queue_name).publish(serialize(hash))
  end

  private

  def self.serialize hash
    hash.to_json
  end

  def self.deserialize hash
    ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(hash[:payload]))
  end
end
