module Certmeister

  module Pipe

    def self.command(command, stdin)
      IO.popen(command, "a+") do |io|
        reader = Thread.new { io.read }
        writer = Thread.new { io.write(stdin); io.flush }
        writer.join
        sleep(0)
        io.close_write
        reader.value
      end
    end

  end

end
