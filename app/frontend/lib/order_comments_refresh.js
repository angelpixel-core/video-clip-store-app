export function insertOrderComment(data) {
  const commentsList = document.querySelector("#order-comments-list")
  const commentsEmptyState = document.querySelector("#order-comments-empty")
  const commentsCount = document.querySelector("#order-comments-count")

  if (!commentsList || !data?.comment_html) return

  if (commentsEmptyState) commentsEmptyState.remove()

  commentsList.insertAdjacentHTML("beforeend", data.comment_html)

  if (commentsCount && typeof data.comment_count === "number") {
    commentsCount.textContent = String(data.comment_count)
  }
}
