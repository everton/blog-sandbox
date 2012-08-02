class Comment < ActiveRecord::Base
  belongs_to :post

  attr_accessible :author, :body, :post

  validates :author, presence: true
  validates :post,   presence: true
end
