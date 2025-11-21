# WebRTC Connection Project

Минимальный проект для соединения двух клиентов Godot через WebRTC с использованием signaling сервера на Go.

## Запуск

1. Запустите signaling сервер:
   ```
   go run main.go
   ```
   Сервер слушает на `localhost:8085`.

2. Запустите два экземпляра Godot проекта.

3. В каждом экземпляре нажмите "Connect to Signaling" — клиенты подключатся к серверу и спарятся.

4. После пары откроется data channel, и вы сможете обмениваться сообщениями через WebRTC.

## Компоненты

- `main.go`: Signaling сервер на Go с gorilla/websocket.
- `main.gd`: Клиент Godot с WebRTC.
- `main.tscn`: Сцена с UI (кнопки, поля ввода, лог чата).

## Требования

- Go 1.24+ с модулем `github.com/gorilla/websocket`.
- Godot 4.5+.