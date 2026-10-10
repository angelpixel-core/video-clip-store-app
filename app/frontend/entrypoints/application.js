import "bootstrap/dist/css/bootstrap.min.css"
import "bootstrap/dist/js/bootstrap.bundle.min.js"
import $ from "jquery"
import { Application } from "@hotwired/stimulus"
import consumer from "../channels/consumer"
import { subscribeToClientNotifications, subscribeToPMNotifications } from "../channels/notifications_channel"
import { subscribeToOrderComments } from "../channels/order_comments_channel"
import { subscribeToOrderStatus } from "../channels/order_status_channel"
import "./application.css"
import OrderActionController from "../controllers/order_action_controller"
import WorkspaceSwitchController from "../controllers/workspace_switch_controller"
import NotificationActionController from "../controllers/notification_action_controller"
import CommentFormController from "../controllers/comment_form_controller"
import OrderFormController from "../controllers/order_form_controller"
import SecretRevealController from "../controllers/secret_reveal_controller"

globalThis.$ = $
globalThis.jQuery = $

const application = Application.start()
application.register("order-form", OrderFormController)
application.register("workspace-switch", WorkspaceSwitchController)
application.register("notification-action", NotificationActionController)
application.register("comment-form", CommentFormController)
application.register("order-action", OrderActionController)
application.register("secret-reveal", SecretRevealController)

subscribeToPMNotifications(consumer)
subscribeToClientNotifications(consumer)
subscribeToOrderComments(consumer)
subscribeToOrderStatus(consumer)

console.log("Vite Rails is ready")
