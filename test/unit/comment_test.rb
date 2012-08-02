require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :posts, :comments

  test "count post" do
    assert_equal 5, Comment.count
  end

  test "find one record" do
    comment = comments(:first_comment_on_first_postage)

    assert_equal comment, Comment.find(comment.id)
  end

  test "find all records" do
    recs = Comment.all
    assert_equal 5, recs.size
    assert(recs.all?{|rec| rec.is_a? Comment },
           "All registers expected to be" +
           " Comment but was <#{recs.inspect}>")
  end

  test "raise RecordNotFound when record doesn't exist" do
    unused_id = 0
    assert_raises ActiveRecord::RecordNotFound do
      unused_id += 1 while Comment.all.map(&:id).include? unused_id

      Comment.find unused_id
    end
  end

  test "create a record with valid data" do
    post = posts(:my_first_postage)

    assert_difference 'Comment.count' do
      @comment = Comment.create post: post, author: 'George',
        body: 'Lorem ipsum'
    end

    assert_equal post, @comment.post
  end

  test "validation of blank author on creation" do
    post = posts(:my_first_postage)

    comment = Comment.new post: post, author: '     ',
      body: 'Lorem ipsum'

    assert_no_difference 'Comment.count' do
      comment.save
    end

    assert comment.errors[:author].include? "can't be blank"
  end

  test "validation of blank post on creation" do
    comment = Comment.new author: 'My Comment',
      body: 'Lorem ipsum'

    assert_no_difference 'Comment.count' do
      comment.save
    end

    assert comment.errors[:post].include? "can't be blank"
  end

  test "update a record" do
    post = posts(:my_first_postage)
    comment = comments(:first_comment_on_first_postage)

    assert_no_difference 'Comment.count' do
      comment.update_attributes post: post, author: 'new author',
        body: 'new body'
    end

    comment.reload
    assert_equal 'new author', comment.author
    assert_equal 'new body',   comment.body
    assert_equal post,         comment.post
  end

  test "validation of blank author on update" do
    comment = comments(:first_comment_on_first_postage)

    assert_no_difference 'Comment.count' do
      comment.update_attributes author: '     '
    end

    assert comment.errors[:author].include? "can't be blank"
  end

  test "delete a record" do
    comment = comments(:first_comment_on_first_postage)

    assert_difference 'Comment.count', -1 do
      comment.destroy
    end

    assert_raises ActiveRecord::RecordNotFound do
      Comment.find comment.id
    end
  end
end
