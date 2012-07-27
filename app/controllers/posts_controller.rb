class PostsController < ApplicationController
  respond_to :html

  def new
    @post = Post.new
    respond_with @post
  end

  def create
    @post = Post.create params[:post]
    respond_with @post
  end
end
