require 'test_helper'

class PostTest < ActiveSupport::TestCase
  fixtures :posts

  test "count post" do
    assert_equal 2, Post.count
  end

  test "find one record" do
    first_post = posts(:my_first_postage)

    assert_equal first_post, Post.find(first_post.id)
  end

  test "find all records" do
    recs = Post.all
    assert_equal 2, recs.size
    assert(recs.all?{|rec| rec.is_a? Post },
           "All registers expected to be" +
           " Post but was <#{recs.inspect}>")
  end

  test "raise RecordNotFound when record doesn't exist" do
    unused_id = 0
    assert_raises ActiveRecord::RecordNotFound do
      unused_id += 1 while Post.all.map(&:id).include? unused_id

      Post.find unused_id
    end
  end

  test "create a record with valid data" do
    assert_difference 'Post.count' do
      Post.create title: 'My third post', body: 'Lorem ipsum'
    end
  end

  test "validation of blank title on creation" do
    post = Post.new title: '     ', body: 'Lorem ipsum'
    assert_no_difference 'Post.count' do
      post.save
    end

    assert post.errors[:title].include? "can't be blank"
  end

  test "update a record" do
    post = posts(:my_first_postage)
    assert_no_difference 'Post.count' do
      post.update_attributes title: 'new title', body: 'new body'
    end

    post.reload
    assert_equal 'new title', post.title
    assert_equal 'new body',  post.body
  end

  test "validation of blank title on update" do
    post = posts(:my_first_postage)
    assert_no_difference 'Post.count' do
      post.update_attributes title: '     '
    end

    assert post.errors[:title].include? "can't be blank"
  end

  test "delete a record" do
    post = posts(:my_first_postage)
    assert_difference 'Post.count', -1 do
      post.destroy
    end

    assert_raises ActiveRecord::RecordNotFound do
      Post.find post.id
    end
  end
end
