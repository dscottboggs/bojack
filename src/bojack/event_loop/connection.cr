require "socket"
require "../logger"
require "../request"
require "./message"

module BoJack
  module EventLoop
    class Connection
      @logger : BoJack::Logger = BoJack::Logger.instance

      def initialize(@server : TCPServer | UNIXServer, @channel : ::Channel::Unbuffered(BoJack::Request)); end

      def start
        loop do
          if socket = @server.accept?
            if socket.class == TCPSocket
              sock = socket.as(TCPSocket)
              @logger.info("#{sock.remote_address} connected")
              Message.new(sock, @channel).start
            else
              sock = socket.as(UNIXSocket)
              @logger.info("#{sock.remote_address} connected")
              Message.new(sock, @channel).start
            end
          end
        end
      end

    end
  end
end
