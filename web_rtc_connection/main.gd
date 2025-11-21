extends Control

var ws := WebSocketPeer.new()
var rtc_conn := WebRTCPeerConnection.new()
var rtc_peer := WebRTCMultiplayerPeer.new()
var signaling_connected := false

func _ready():
	multiplayer.multiplayer_peer = rtc_peer
	$Button.text = "Connect to Signaling"
	$Button.pressed.connect(Callable(self, "_on_button_pressed"))
	$SendButton.pressed.connect(Callable(self, "_on_send_pressed"))
	$SendButton.disabled = true

func _on_button_pressed():
	if not signaling_connected:
		var err = ws.connect_to_url("ws://localhost:8085/ws")
		if err != OK:
			push_error("Failed to connect to signaling server")
			return
		signaling_connected = true
		$Button.text = "Waiting for pair..."

func _on_session_description_created(type: String, sdp: String):
	var msg = {"type": type, "sdp": sdp}
	ws.send_text(JSON.stringify(msg))

func _on_ice_candidate_created(media: String, index: int, candidate_name: String):
	var msg = {"type": "candidate", "candidate": candidate_name, "sdpMLineIndex": index, "sdpMid": media}
	ws.send_text(JSON.stringify(msg))

func _process(_delta):
	ws.poll()
	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while ws.get_available_packet_count() > 0:
			var packet = ws.get_packet()
			var msg = JSON.parse_string(packet.get_string_from_utf8())
			_handle_signaling(msg)
	elif state == WebSocketPeer.STATE_CLOSED:
		signaling_connected = false

	# Check for WebRTC packets
	while rtc_peer.get_available_packet_count() > 0:
		var packet = rtc_peer.get_packet()
		var msg = packet.get_string_from_utf8()
		$ChatLog.text += "Peer: " + msg + "\n"

func _handle_signaling(msg: Dictionary):
	if msg["type"] == "paired":
		$Label.text = "Paired with another client as " + msg["role"]
	if msg["role"] == "initiator":
		rtc_conn.initialize({
			"iceServers": [
				{"urls": ["stun:stun.l.google.com:19302"]}
			]
		})
		rtc_peer.add_peer(rtc_conn, 1)
		rtc_conn.session_description_created.connect(Callable(self, "_on_session_description_created"))
		rtc_conn.ice_candidate_created.connect(Callable(self, "_on_ice_candidate_created"))
		rtc_peer.peer_connected.connect(Callable(self, "_on_peer_connected"))

		var offer = rtc_conn.create_offer()
		rtc_conn.set_local_description(offer["type"], offer["sdp"])
	elif msg["type"] == "offer":
		rtc_conn.initialize({
			"iceServers": [
				{"urls": ["stun:stun.l.google.com:19302"]}
			]
		})
		rtc_peer.add_peer(rtc_conn, 1)
		rtc_conn.session_description_created.connect(Callable(self, "_on_session_description_created"))
		rtc_conn.ice_candidate_created.connect(Callable(self, "_on_ice_candidate_created"))
		rtc_peer.peer_connected.connect(Callable(self, "_on_peer_connected"))
		rtc_conn.set_remote_description(msg["type"], msg["sdp"])
		var answer = rtc_conn.create_answer()
		rtc_conn.set_local_description(answer["type"], answer["sdp"])
	elif msg["type"] == "answer":
		rtc_conn.set_remote_description(msg["type"], msg["sdp"])
	elif msg["type"] == "candidate":
		rtc_conn.add_ice_candidate(msg["sdpMid"], msg["sdpMLineIndex"], msg["candidate"])

func _on_send_pressed():
	if rtc_peer.get_peers().size() > 0:
		var msg = $MessageInput.text
		rtc_peer.put_packet(msg.to_utf8_buffer())
		$ChatLog.text += "You: " + msg + "\n"
		$MessageInput.text = ""

func _on_peer_connected(id):
	$Label.text = "Peer connected: %d" % id
	$SendButton.disabled = false
