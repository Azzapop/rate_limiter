class Limiter
  TIME_LIMIT = 60.minutes.to_i # minutes as seconds
  MAX_REQUESTS = 100

  attr_accessor :app, :env

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    return cancelled_request if rate_limit_reached
    @app.call(@env)
  end

  def rate_limit_reached
    if !request_count
      # Set to 0 as we incr to 1 for this request
      REDIS.set(application_key, 0, ex: TIME_LIMIT)
    elsif request_count >= MAX_REQUESTS
      return true
    end
    REDIS.incr(application_key)
    return false
  end

  def cancelled_request
    ttl = REDIS.ttl(application_key)
    return [
      429,
      {
        'X-RateLimit-Limit' => MAX_REQUESTS,
        'X-RateLimit-Remaining' => MAX_REQUESTS - request_count
      },
      [{:message => "Rate limit exceeded. Try again in #{ttl} seconds."}.to_json]
    ]
  end

  def request_count
    REDIS.get(application_key).try(:to_i)
  end

  def application_key
    env['REMOTE_ADDR']
  end
end
