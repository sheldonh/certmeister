module Certmeister

  module Pipe

    def self.command(command, stdin)
      IO.popen(command, "a+") do |io|
        reader = Thread.new { io.read }
        io.flush
        sleep(0)
        writer = Thread.new { io.write(stdin) }
        writer.join
        io.close_write
        reader.value
      end
    end

  end

end
