module Artoo
  module Drivers
    # The Driver class is the base class used to  
    # implement behavior for a specific kind of hardware devices. Examples 
    # would be an Arduino, a Sphero, or an ARDrone.
    #
    # Derive a class from this class, in order to implement behavior
    # for a new type of hardware device.
    class Driver
      include Celluloid
      include Celluloid::Notifications
      
      attr_reader :parent

      COMMANDS = [].freeze

      def initialize(params={})
        @parent = params[:parent]
      end

      def connection
        parent.connection
      end

      def pin
        parent.pin
      end

      def interval
        parent.interval
      end

      def start_driver
        Logger.info "Starting driver '#{self.class.name}'..."
      end

      def event_topic_name(event)
        parent.event_topic_name(event)
      end

      def commands
        self.class.const_get('COMMANDS')
      end

      def known_command?(method_name)
        commands.include?(method_name)
      end

      def method_missing(method_name, *arguments, &block)
        Logger.warn("Calling unknown command '#{method_name}'...") unless known_command?(method_name)

        connection.send(method_name, *arguments, &block)
      rescue Exception => e
        Logger.error e.message
        Logger.error e.backtrace.inspect
        return nil
      end
    end
  end
end