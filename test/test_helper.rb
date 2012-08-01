ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def assert_action_title(title)
    assert_select "title", "Blog | #{title}"
    assert_select "h1", title
  end

  def assert_success_on_get_to(action, options = {})
    format = options.delete(:as) || :html
    request.env["HTTP_ACCEPT"] = Mime[format]

    get action, options

    assert_response :success
    assert_equal Mime[format], response.content_type
  end
end
