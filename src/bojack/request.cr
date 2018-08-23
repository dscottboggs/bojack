require "socket"
require "./logger"
require "./command"

module BoJack
  class Request
    @logger : BoJack::Logger = BoJack::Logger.instance

    def initialize(@body : String, @socket : TCPSocket | UNIXSocket); end

    def unix_socket_server?
      @socket.class == UNIXSocket
    end
    def perform
      if unix_socket_server?
        @logger.info("#{@socket.as(UNIXSocket).remote_address} requested: #{@body.strip}")
      else
        @logger.info("#{@socket.as(TCPSocket).remote_address} requested: #{@body.strip}")
      end
      params = parse(@body)
      command = BoJack::Command.from(params[:command])

      response = command.run(@socket, params)

      @socket.puts(response)
    rescue e
      message = "error: #{e.message}"
      @logger.error(message)
      @socket.puts(message)
    end

    private def parse(body) : Hash(Symbol, String | Array(String))
      body = body.split(" ").map { |item| item.strip }

      command = body[0]
      result = Hash(Symbol, String | Array(String)).new
      result[:command] = command

      result[:key] = body[1] if body[1]?
      result[:value] = body[2].split(",") if body[2]?

      result
    end
  end
end
