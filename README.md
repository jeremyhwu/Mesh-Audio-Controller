# Mesh-Audio-Controller
Ios application for senior project (wireless mesh audio system). Our system allows users to stream audio from a phone or laptop to multiple speakers simultaneously. This application allows users to discover and connect to nodes in the mesh audio system through Bluetooth Low Energy(BLE). Once connected, the app can read/write to the node using the node's services/characteristics.

# Project Structure
The project is structured in Model View Controller form. The main controller is the DevicesViewController, which allows users to scan for devices and connect to them. The other important controller is the DevicesDetailController, which provides all of the functionality to interact with individual peripherals.

# Features
- Add/remove devices from the network
- Mute devices
- Send custom data
- Change volume
- Play/pause music
