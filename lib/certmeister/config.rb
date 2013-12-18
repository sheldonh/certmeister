module Certmeister

  class Config

    attr_reader :ca_cert, :ca_key, :store, :authenticator

    def initialize(options)
      @options = options
      @ca_cert = options[:ca_cert]
      @ca_key = options[:ca_key]
      @store = options[:store]
      @authenticator = options[:authenticator]
      @errors = {}
    end

    def valid?
      validate
      @errors.empty?
    end

    def errors
      @errors
    end

    def error_list
      @errors.keys.sort.inject([]) do |list, option|
        list << "#{option} #{@errors[option]}"
      end
    end

    private

    def validate
      validate_required_file(:ca_cert)
      validate_required_file(:ca_key)
      validate_store(:store)
      validate_unary_callable(:authenticator)
      validate_known_options
    end

    def validate_required_file(option)
      if not @options[option]
        @errors[option] = "is required"
      elsif not File.exists?(@options[option])
        @errors[option] = "must name an existing file"
      end
    end

    def validate_store(option)
      o = @options[option]
      if not o
        @errors[option] = "is required"
      elsif not o.respond_to?(:store) or o.method(:store).arity != 2
        @errors[option] = "must provide a binary store method"
      elsif not o.respond_to?(:fetch) or o.method(:fetch).arity != 1
        @errors[option] = "must provide a unary fetch method"
      elsif not o.respond_to?(:health_check) or o.method(:health_check).arity != 1
        @errors[option] = "must provide a nullary health_check method"
      end
    end

    def validate_unary_callable(option)
      o = @options[option]
      if o and not (o.respond_to?(:call) and o.respond_to?(:arity) and o.arity == 1)
        @errors[option] = "must be a unary callable if given"
      end
    end

    def validate_known_options
      unexpected = @options.keys - [:ca_cert, :ca_key, :store, :authenticator]
      unexpected.each do |option|
        @errors[option] = "is not a supported option"
      end
    end

  end

end
