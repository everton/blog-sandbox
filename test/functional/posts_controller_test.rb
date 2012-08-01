require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  test "GET to /posts as HTML" do
    assert_routing({path: '/posts', method: :get},
                   {controller: "posts", action: "index"})

    request.env["HTTP_ACCEPT"] = Mime[:html]

    get :index

    assert_response :success
    assert_equal Mime[:html], response.content_type

    assert_not_nil assigns(:posts)
    assert_equal Post.all, assigns(:posts)

    assert_select "title", "Blog | Posts"
    assert_select "h1", "Posts"

    assert_select 'ol#posts' do
      assert_select 'li', Post.count

      Post.all.each do |post|
        assert_select("li a[href=#{post_path(post)}]",
                      {count: 1, text: post.title})
      end
    end
  end

  test "POST to /posts as HTML with valid parameters" do
    request.env["HTTP_ACCEPT"] = Mime[:html]

    assert_routing({path: '/posts', method: :post},
                   {controller: "posts", action: "create"})

    assert_difference "Post.count" do
      post :create, post: {
        title: 'My third post', body: 'Lorem ipsum'
      }

      assert_equal Mime[:html], response.content_type
      assert_not_nil assigns(:post)

      assert_redirected_to post_path(assigns(:post))
    end
  end

  test "GET to /posts/new as HTML" do
    request.env["HTTP_ACCEPT"] = Mime[:html]

    assert_routing({path: '/posts/new', method: :get},
                   {controller: "posts", action: "new"})

    get :new

    assert_response :success
    assert_equal Mime[:html], response.content_type

    assert_not_nil assigns(:post)
    assert assigns(:post).new_record?

    assert_select 'title', 'Blog | New Post'
    assert_select 'h1', 'New Post'

    assert_select 'form[action=/posts][method=post]' do
      assert_select "label[for=post_title]", 'Title'
      assert_select "input[type=text][name='post[title]']"

      assert_select "label[for=post_body]", 'Body'
      assert_select "textarea[name='post[body]']"

      assert_select 'input[type=submit][value=Submit]'
    end
  end

  test "POST to /posts as HTML with INVALID parameters" do
    request.env["HTTP_ACCEPT"] = Mime[:html]

    assert_routing({path: '/posts', method: :post},
                   {controller: "posts", action: "create"})

    assert_no_difference "Post.count" do
      post :create, post: {
        title: '     ', body: 'Lorem ipsum'
      }

      assert_equal Mime[:html], response.content_type

      assert_response :success
      assert_template :new

      assert_not_nil  assigns(:post)
      assert_equal 1, assigns(:post).errors.count

      assert_select "form[action=/posts][method=post]" do
        assert_select '#error_explanation' do
          assert_select 'li', "Title can't be blank"
        end

        assert_select("textarea[name='post[body]']",
                      assigns(:post).body)
      end
    end
  end
end
