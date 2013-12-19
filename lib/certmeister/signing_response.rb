module Certmeister

  class SigningResponse

    def initialize(pem, error = nil)
      @pem = pem
      @error = error
    end

    def signed?
      !@error
    end

    def pem
      @pem unless @error
    end

    def error
      @error
    end

  end

end
