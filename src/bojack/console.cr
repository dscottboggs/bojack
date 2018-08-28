require "readline"
require "../../../bojack.cr/src/bojack-client"

module BoJack
  class Console
    @client : BoJack::Client?

    def initialize(hostname : String = "127.0.0.1",
                   port : UInt16 = 5000,
                   socket_path : String = "")
      @hostname = socket_path.empty? ? hostname : socket_path
      @port = port
      begin
        @client = BoJack::Client.new(
          hostname: hostname,
          port: port,
          socket_path: socket_path
        )
      rescue exception
        puts exception.message
        exit -1
      end
    end

    def start
      client = @client
      return unless client
      loop do
        input = Readline.readline("> ", true)
        puts client.send(input)
        break if input == "close"
      end
    end
  end
end
