import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/fallblatt_ui"
import "@carbon/web-components/es/index.js"
import "@carbon/styles/css/styles.css"
import {CarbonEvents} from "carbon_phoenix"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, CarbonEvents},
})

liveSocket.connect()
window.liveSocket = liveSocket
