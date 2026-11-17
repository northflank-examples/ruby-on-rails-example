require "test_helper"

# Characterization tests guarding framework-level behavior this template relies on.
class ApplicationSmokeTest < ActionDispatch::IntegrationTest
  test "serves static files from public/" do
    get "/robots.txt"
    assert_response :success

    get "/404.html"
    assert_response :success
  end

  test "unknown routes raise instead of rendering error pages in test" do
    assert_raises(ActionController::RoutingError) do
      get "/this-route-does-not-exist"
    end
  end

  test "application layout renders stylesheet and importmap tags" do
    html = ApplicationController.render(inline: "<p>hello</p>", layout: "application")

    assert_includes html, "<p>hello</p>"
    assert_match %r{<link[^>]+stylesheet[^>]+/assets/application}, html
    assert_includes html, %(type="importmap")
    assert_includes html, "@hotwired/turbo-rails"
  end

  test "host authorization accepts a single host string as provided via NF_HOSTS" do
    app = ->(_env) { [200, { "Content-Type" => "text/plain" }, ["ok"]] }
    middleware = ActionDispatch::HostAuthorization.new(app, "allowed.example.org")

    allowed = middleware.call(Rack::MockRequest.env_for("http://allowed.example.org/", "HTTP_HOST" => "allowed.example.org"))
    assert_equal 200, allowed.first

    blocked = middleware.call(Rack::MockRequest.env_for("http://evil.example.com/", "HTTP_HOST" => "evil.example.com"))
    assert_equal 403, blocked.first
  end

  test "mailer defaults are preserved" do
    assert_equal "from@example.com", ApplicationMailer.default[:from]
    assert_equal "mailer", ApplicationMailer._layout
  end

  test "application record is the primary abstract class" do
    assert ApplicationRecord.abstract_class?
  end
end
