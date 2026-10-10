class Comment < ApplicationRecord
  after_create_commit :broadcast_refresh

  belongs_to :project, class_name: "Order", foreign_key: :project_id
  belongs_to :author_account, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :author_account_id

  validates :body, presence: true
  validates :author_account, presence: true

  scope :chronological, -> { order(created_at: :asc) }

  before_validation :sync_legacy_author_columns

  def author
    author_account || Identity::Domain::Aggregates::Account.find_by(id: author_id)
  end

  def author=(value)
    self.author_account = value
    self.author_type = value.class.name
    self.author_id = value.id
  end

  def order
    project
  end

  def order=(value)
    self.project = value
  end

  def self.broadcast_refresh_for(project)
    return unless project.present?

    comment = project.comments.includes(:author_account).order(created_at: :desc).first
    return unless comment.present?

    ActionCable.server.broadcast(
      "order_comments_#{project.id}",
      {
        type: "comments_updated",
        comment_html: ApplicationController.render(partial: "orders/comment", locals: { comment: comment }),
        comment_count: project.comments.count
      }
    )
  end

  private

  def broadcast_refresh
    self.class.broadcast_refresh_for(project)
  end

  def sync_legacy_author_columns
    return if author_account.blank?

    self.author_type = author_account.class.name
    self.author_id ||= author_account.id
  end
end
