require "socket"
require "../logger"
require "../request"
require "./message"

module BoJack
  module EventLoop
    class Connection
      @logger : BoJack::Logger = BoJack::Logger.instance

      def initialize(@server : TCPServer, @channel : ::Channel::Unbuffered(BoJack::Request), @resp = false); end

      def start
        loop do
          if socket = @server.accept?
            @logger.info("#{socket.remote_address} connected")

            Message.new(socket, @channel, @resp).start
          end
        end
      end
    end
  end
end
