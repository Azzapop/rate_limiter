class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    REDIS.flushall
  end
  test "should not rate limit at 100 requests per hour" do
    100.times { get rand_url }
    assert_response 200
  end
  test "should rate limit at more than 100 requests per hour" do
    101.times { get rand_url }
    assert_response 429
  end
end
