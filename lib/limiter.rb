class Limiter
  TIME_LIMIT = 60.minutes.to_i # minutes as seconds
  MAX_REQUESTS = 100

  attr_accessor :app, :env

  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    hits = REDIS.get(application_key).try(:to_i)
    if !hits
      REDIS.set(application_key, 1, ex: TIME_LIMIT)
    elsif hits >= MAX_REQUESTS
      ttl = REDIS.ttl(application_key)
      return [
        429,
        {
          'X-RateLimit-Limit' => MAX_REQUESTS,
          'X-RateLimit-Remaining' => MAX_REQUESTS - hits
        },
        [{:message => "Rate limit exceeded. Try again in #{ttl} seconds."}.to_json]
      ]
    else
      REDIS.incr(application_key)
    end
    @app.call(@env)
  end

  def application_key
    @env['REMOTE_ADDR']
  end
end
