# Rate Limiter

The rate limiter can be found in `lib/limiter.rb`. It limits API requests to 100 requests per 60 minutes. This limit can be modified using the `TIME_LIMIT` and `MAX_REQUESTS` vars located in the aforementioned file. The limiter is implemented as a middleware and is loaded in the main application file (`config/application.rb`).

The rate limiter uses Redis to cache each requester and measure their requests per hour.

---

### Development

Set env var `REDIS_URL` (for development this would most likely be `redis://localhost:6379/0/cache`)

Requires `Redis`

To begin, `bundle install` then `rails s`

---

### Tests

Run tests using `rails test`
