require 'spec_helper'

require 'certmeister'

describe Certmeister::Pipe do

  it "pipes a string through a command" do
    stdout = Certmeister::Pipe.command("cat", "Hello, world!")
    expect(stdout).to eql "Hello, world!"
  end

  it "does not block on large input" do
    test = -> do
      Timeout::timeout(1) do
        stdin = "x" * (256 * 4096 + 1)
        stdout = Certmeister::Pipe.command("cat", stdin)
        expect(stdout).to eql stdin
      end
    end
    expect { test.call }.to_not raise_error
  end

  it "does not capture stderr" do
    stdout = Certmeister::Pipe.command("sh -c 'read junk; echo an error message 1>&2'", "Ignored input")
    expect(stdout).to eql ""
  end

  it "does no capture exceptions" do
    expect { Certmeister::Pipe.command("/nosuchfile", "Orphaned input") }.to raise_error(Errno::ENOENT)
  end

end
