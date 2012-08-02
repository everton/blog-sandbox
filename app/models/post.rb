class Post < ActiveRecord::Base
  has_many :comments, order: :created_at

  attr_accessible :body, :title

  validates :title, presence: true
end
