require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  fixtures :posts

  test "GET to /posts as HTML" do
    assert_routing({path: '/posts', method: :get},
                   {controller: "posts", action: "index"})

    assert_success_on_get_to :index, as: :html

    assert_not_nil assigns(:posts)
    assert_equal Post.all, assigns(:posts)

    assert_action_title 'Posts'

    assert_select 'ol#posts' do
      assert_select 'li', Post.count

      Post.all.each do |post|
        assert_select("li a[href=#{post_path(post)}]",
                      {count: 1, text: post.title})
      end
    end
  end

  test "GET to /posts as XML" do
    assert_routing({path: '/posts', method: :get, format: :xml},
                   {controller: "posts", action: "index"})

    assert_success_on_get_to :index, as: :xml

    assert_not_nil assigns(:posts)
    assert_equal Post.all, assigns(:posts)

    assert_equal Post.all.to_xml, response.body
  end

  test "GET to /posts/1 as HTML" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}", method: :get},
                   {controller: "posts", action: "show", id: post.to_param})

    assert_success_on_get_to :show, id: post.id, as: :html

    assert_not_nil     assigns(:post)
    assert_equal post, assigns(:post)

    assert_action_title post.title

    assert_select 'article#post_body', post.body
  end

  test "GET to /posts/1 as XML" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}", method: :get, format: :xml},
                   {controller: "posts", action: "show", id: post.to_param})

    assert_success_on_get_to :show, id: post.id, as: :xml

    assert_not_nil assigns(:post)
    assert_equal post, assigns(:post)

    assert_equal post.to_xml, response.body
  end

  test "POST to /posts as HTML with valid parameters" do
    request.env["HTTP_ACCEPT"] = Mime[:html]

    assert_routing({path: '/posts', method: :post},
                   {controller: "posts", action: "create"})

    assert_difference "Post.count" do
      post :create, post: {
        title: 'My third post', body: 'Lorem ipsum'
      }
    end

    assert_equal Mime[:html], response.content_type
    assert_not_nil assigns(:post)

    assert_redirected_to post_path(assigns(:post))
  end

  test "POST to /posts as XML with valid parameters" do
    request.env["HTTP_ACCEPT"] = Mime[:xml]

    assert_routing({path: '/posts', method: :post},
                   {controller: "posts", action: "create"})

    assert_difference "Post.count" do
      post :create, post: {
        title: 'My third post', body: 'Lorem ipsum'
      }
    end

    assert_equal Mime[:xml], response.content_type
    assert_not_nil assigns(:post)

    assert_equal assigns(:post).to_xml, response.body
  end

  test "GET to /posts/new as HTML" do
    assert_routing({path: '/posts/new', method: :get},
                   {controller: "posts", action: "new"})

    assert_success_on_get_to :new, as: :html

    assert_not_nil assigns(:post)
    assert assigns(:post).new_record?

    assert_action_title 'New Post'

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
    end

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

  test "POST to /posts as XML with INVALID parameters" do
    request.env["HTTP_ACCEPT"] = Mime[:xml]

    assert_routing({path: '/posts', method: :post},
                   {controller: "posts", action: "create"})

    assert_no_difference "Post.count" do
      post :create, post: {
        title: '     ', body: 'Lorem ipsum'
      }
    end

    assert_equal Mime[:xml], response.content_type

    assert_response :unprocessable_entity

    assert_not_nil  assigns(:post)
    assert_equal 1, assigns(:post).errors.count
    assert_equal assigns(:post).errors.to_xml, response.body
  end

  test "GET to /posts/1/edit as HTML" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}/edit", method: :get},
                   {controller: "posts", action: "edit", id: post.to_param})

    assert_success_on_get_to :edit, id: post.to_param, as: :html

    assert_not_nil     assigns(:post)
    assert_equal post, assigns(:post)

    assert_action_title "Edit post #{post.title}"

    assert_select "form[action=/posts/#{post.id}][method=post]" do
      assert_select "input[type=hidden][name='_method'][value='put']"

      assert_select "label[for=post_title]", 'Title'
      assert_select "input[type=text][name='post[title]']" +
        "[value='#{post.title}']"

      assert_select "label[for=post_body]", 'Body'
      assert_select "textarea[name='post[body]']", post.body

      assert_select 'input[type=submit][value=Submit]'
    end
  end

  test "PUT to /posts/1 as HTML with valid parameters" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}", method: :put},
                   {controller: "posts", action: "update", id: post.to_param})

    request.env["HTTP_ACCEPT"] = Mime[:html]

    assert_no_difference "Post.count" do
      put :update, id: post.id, post: {
        title: 'My edited post'
      }

      assert_equal Mime[:html], response.content_type

      assert_not_nil assigns(:post)
      assert_equal 'My edited post', assigns(:post).title

      assert_redirected_to post_path(assigns(:post))
    end
  end

  test "PUT to /posts/1 as XML with valid parameters" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}", method: :put},
                   {controller: "posts", action: "update", id: post.to_param})

    request.env["HTTP_ACCEPT"] = Mime[:xml]

    assert_no_difference "Post.count" do
      put :update, id: post.id, post: {
        title: 'My edited post'
      }
    end

    assert_equal Mime[:xml], response.content_type
    assert_response :success

    assert_not_nil assigns(:post)
    assert_equal 'My edited post', assigns(:post).title
  end

  test "PUT to /posts/1 as HTML with INVALID parameters" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}", method: :put},
                   {controller: "posts", action: "update", id: post.to_param})

    request.env["HTTP_ACCEPT"] = Mime[:html]

    assert_no_difference "Post.count" do
      put :update, id: post.id, post: {
        title: '     '
      }
    end

    assert_response :success
    assert_template :edit
    assert_equal Mime[:html], response.content_type

    assert_not_nil  assigns(:post)
    assert_equal 1, assigns(:post).errors.count

    assert_action_title "Edit post #{post.title}"

    assert_select "form[action=/posts/#{post.id}][method=post]" do
      assert_select "input[type=hidden][name='_method'][value='put']"

      assert_select '#error_explanation' do
        assert_select 'li', "Title can't be blank"
      end

      assert_select "label[for=post_title]", 'Title'
      assert_select "input[type=text][name='post[title]']" +
        "[value='     ']"

      assert_select "label[for=post_body]", 'Body'
      assert_select "textarea[name='post[body]']", post.body

      assert_select 'input[type=submit][value=Submit]'
    end
  end

  test "PUT to /posts/1 as XML with INVALID parameters" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}", method: :put},
                   {controller: "posts", action: "update", id: post.to_param})

    request.env["HTTP_ACCEPT"] = Mime[:xml]

    assert_no_difference "Post.count" do
      put :update, id: post.id, post: {
        title: '     '
      }
    end

    assert_response :unprocessable_entity
    assert_equal Mime[:xml], response.content_type

    assert_not_nil  assigns(:post)
    assert_equal 1, assigns(:post).errors.count
    assert_equal assigns(:post).errors.to_xml, response.body
  end

  test "DELETE to /posts/1 as HTML" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}", method: :delete},
                   {controller: "posts", action: "destroy", id: post.to_param})

    request.env["HTTP_ACCEPT"] = Mime[:html]

    assert_difference "Post.count", -1 do
      delete :destroy, id: post.id
    end

    assert_equal 'Post was successfully deleted', flash[:notice]
    assert_redirected_to posts_path
  end

  test "DELETE to /posts/1 as XML" do
    post = posts(:my_first_postage)

    assert_routing({path: "/posts/#{post.id}", method: :delete},
                   {controller: "posts", action: "destroy", id: post.to_param})

    request.env["HTTP_ACCEPT"] = Mime[:xml]

    assert_difference "Post.count", -1 do
      delete :destroy, id: post.id
    end

    assert_equal Mime[:xml], response.content_type

    assert_equal 'Post was successfully deleted', flash[:notice]

    assert_response :no_content
  end
end
