module Certmeister

  class FetchingResponse

    def initialize(pem, error = nil)
      @pem = pem
      @error = error
    end

    def fetched?
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
