require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  test "POST to /posts as HTML with valid parameters" do
    request.env["HTTP_ACCEPT"] = Mime[:html]

    assert_routing({path: '/posts', method: :post},
                   {controller: "posts", action: "create"})
  end
end
