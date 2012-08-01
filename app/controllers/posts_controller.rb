class PostsController < ApplicationController
  respond_to :html

  def index
    @posts = Post.all
  end

  def new
    @post = Post.new
    respond_with @post
  end

  def create
    @post = Post.create params[:post]
    respond_with @post
  end
end
