class Comment < ActiveRecord::Base
  attr_accessible :author, :body, :post
end
