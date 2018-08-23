require "socket"
require "./memory"
require "./logger"
require "./request"
require "./logo"
require "./event_loop/*"

module BoJack
  class Server
    @server : TCPServer | UNIXServer
    @socket_path : String?
    @logger : BoJack::Logger = BoJack::Logger.instance
    @@memory : BoJack::Memory(String, Array(String)) = BoJack::Memory(String, Array(String)).new

    def initialize(@hostname : String = "127.0.0.1", @port : UInt16 = 5000)
      @address = "tcp://#{hostname}:#{port}"
      server = TCPServer.new(@hostname, @port)
      server.tcp_nodelay = true
      server.recv_buffer_size = 4096
      @server = server
    end

    def initialize(*, # makes all arguments required to be specified by name.
                   hostname    : String = "127.0.0.1",
                   port        : UInt16 = 5000,
                   socket_path : String)
      if socket_path.empty?
        @port = port.to_u16
        @hostname = hostname
        @address = "tcp://#{hostname}:#{port}"
        server = TCPServer.new(hostname, port)
        server.tcp_nodelay = true
        server.recv_buffer_size = 4096
        @server = server
      else
        @socket_path = socket_path
        @port = 0.to_u16
        @hostname = @address = "unix://#{socket_path}"
        server = UNIXServer.new socket_path
        server.recv_buffer_size = 4096
        @server = server
      end
    end

    def unix_socket_server?
      return @port == 0
    end

    def start
      print_logo
      handle_signal_trap
      start_connection_loop
    end

    private def print_logo
      BoJack::Logo.render(@logger)
    end

    private def handle_signal_trap
      if unix_socket_server?
        BoJack::EventLoop::Signal.new.watch @server.as UNIXServer
      else
        BoJack::EventLoop::Signal.new.watch @server.as TCPServer
      end
    end

    private def start_connection_loop
      @logger.info("BoJack is running at #{@address}")

      channel = Channel::Unbuffered(BoJack::Request).new
      BoJack::EventLoop::Channel(BoJack::Request).new(channel).start

      if unix_socket_server?
        BoJack::EventLoop::Connection.new(@server.as(UNIXServer), channel).start
      else
        BoJack::EventLoop::Connection.new(@server.as(TCPServer), channel).start
      end
    end

    def self.memory
      @@memory
    end
  end
end
