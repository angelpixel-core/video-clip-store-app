class CommentsController < ApplicationController
  before_action :load_project

  def create
    @comment = @project.comments.new(comment_params.except(:author_role))
    @comment.author = comment_author

    if @comment.save
      create_comment_notification!(@comment)
      redirect_to order_path(@project, anchor: "order-comments"), notice: "Comment posted."
    else
      @comments = @project.comments.chronological.includes(:author_account)
      render "orders/show", status: :unprocessable_content
    end
  end

  private

  def load_project
    @project = project_repository.find_for_show(params[:order_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :author_role)
  end

  def comment_author
    comment_params[:author_role] == "pm" ? workspace_for(:pm) : workspace_for(:client)
  end

  def create_comment_notification!(comment)
    if comment.author.pm?
      Notification.create!(project: @project, client: @project.owner, kind: "comment_created", body: "New comment from PM on #{@project.name.presence || 'Untitled project'}.")
    else
      Notification.create!(project: @project, pm: @project.participant, kind: "comment_created", body: "New comment from client on #{@project.name.presence || 'Untitled project'}.")
    end
  end

  def project_repository
    @project_repository ||= Fulfillment::Adapters::Persistence::Order::Repository.new
  end
end
