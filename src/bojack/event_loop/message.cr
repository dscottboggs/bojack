require "socket"
require "../request"

module BoJack
  module EventLoop
    class Message
      def initialize(
        @socket : TCPSocket | UNIXSocket,
        @channel : ::Channel::Unbuffered(BoJack::Request)
      ); end

      def unix_socket_server?
        @socket.class == UNIXSocket
      end

      def start
        spawn do
          loop do
            message = @socket.gets
            break unless message

            if unix_socket_server?
              @channel.send(BoJack::Request.new(message, @socket.as(UNIXSocket)))
            else
              @channel.send(BoJack::Request.new(message, @socket.as(TCPSocket)))
            end
          end
        end
      end
    end
  end
end
