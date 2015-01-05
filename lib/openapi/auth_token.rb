module OpenAPI
  class AuthToken
    attr_accessor :header, :key, :options,  :header_format, :expires_at, :expires, :expires_in, :token, :refresh_token

    class << self
      attr_accessor :key

      def fetch_or_create(key, opts)
        auth_token = fetch(key)
        if auth_token.nil? || auth_token.renew?
          self.class.new(opts)
        else
          auth_token
        end
      end

      def fetch(key)
        if OpenAPI.cache
          begin
            puts "fetch new: #{OpenAPI.cache.get(key)}"
            return self.new(JSON.parse(OpenAPI.cache.get(key)))
          rescue => e
            puts e.message
          end
        end
      end

      def key
        @key ||= self.name
      end
    end

    def key
      @key ||= self.class.key
    end

    def update(opts={}, save=false)
      @options = @options.merge(opts)
      @options.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      @token ||= @options.delete("access_token")
      @options["token"] = @token
      if opts.has_key?("expires_at") && !opts["expires_at"].nil?
        @expires_at = opts["expires_at"].to_i
      elsif opts.has_key?("expires_in") && !opts["expires_in"].nil?
        @options.delete("expires_in")
        @expires_at = Time.now.utc.to_i + opts["expires_in"]
        @options["expires_at"] = @expires_at
      end
      self.save if save
    end

    def [](key)
      @options[key.to_s]
    end

    def initialize(opts={}, save=false)
      @options = {}
      opts = {"token" => nil,
        "refresh_token" => nil,
        "expires_at" => nil,
        "expires_in" => nil,
        "key" => nil,
        "header" => "Authorization",
        "header_format" => "Bearer %s"}.merge(opts)
      update(opts, save)
    end

    def headers
      {header => header_format % @token}
    end

    def expires_in
      (expires_at.to_i - Time.now.utc.to_i).abs
    end

    def save
      if OpenAPI.cache
        OpenAPI.cache.set(key, to_hash.to_json, expires_in + 2.hours)
      end
    end

    def to_hash
      @options
    end

    def token(force_renew=false)
      if renew? || force_renew
        renew_token
      end
      @token
    end

    def renew?
      @token == nil || @expires_at.to_i < Time.now.utc.to_i
    end

    def new_auth_token()
      raise NotImplementedError
    end


    def renew_token
      new_token = self.class.fetch(self.key)
      if new_token.nil? || new_token.renew?
        self.new_auth_token
        self.save
      else
        update(new_token.to_hash)
      end
    end

  end
end
