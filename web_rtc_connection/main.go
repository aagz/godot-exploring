package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for simplicity
	},
}

type Client struct {
	conn *websocket.Conn
	send chan []byte
}

var clients = make(map[*websocket.Conn]*Client)
var pairs = make(map[*websocket.Conn]*websocket.Conn)

func handleConnections(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	defer conn.Close()

	client := &Client{conn: conn, send: make(chan []byte, 256)}
	clients[conn] = client

	// Find a pair
	var pair *websocket.Conn
	for c := range clients {
		if c != conn && pairs[c] == nil {
			pair = c
			break
		}
	}
	if pair != nil {
		pairs[conn] = pair
		pairs[pair] = conn
		// Notify: first connected is initiator
		conn.WriteJSON(map[string]string{"type": "paired", "role": "initiator"})
		pair.WriteJSON(map[string]string{"type": "paired", "role": "responder"})
	}

	for {
		var msg map[string]interface{}
		err := conn.ReadJSON(&msg)
		if err != nil {
			log.Println(err)
			delete(clients, conn)
			if p := pairs[conn]; p != nil {
				delete(pairs, p)
				delete(pairs, conn)
			}
			break
		}

		if pair := pairs[conn]; pair != nil {
			pair.WriteJSON(msg)
		}
	}
}

func main() {
	http.HandleFunc("/ws", handleConnections)
	fmt.Println("Signaling server started on :8085")
	log.Fatal(http.ListenAndServe(":8085", nil))
}
