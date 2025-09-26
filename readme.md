# Raspberry Pi Security Camera Mk1

This is the finished (if not totally polished) product of my first attempt at designing a security camera based on a Raspberry Pi and the HQ camera module. I wanted to build an IP camera that a Frigate server could easily read a stream from and where I could control the hardware and software to make sure nothing is phoning home or exposing my home network to vulnerabilities.

## Software Installation

Set up your Raspberry Pi with your desired network, hostname, and any other services/config. Make sure everything is up to date:

```sh
sudo apt update
sudo apt upgrade
```

Clone this repository, then run the install script:

```sh
git clone https://github.com/justincardoza/pi-security-camera-mk1
cd pi-security-camera-mk1
./install.sh
```

It will download the dependencies, install them, and set up a system service to run on the next boot. Reboot to make sure everything is finalized and the services are started.

## Streams

To check that everything is working, you can go to `http://<CAMERA_ADDRESS>:8889/main` to (hopefully) see a nice WebRTC stream from the camera. The URLs for the streams come from [MediaMTX](https://mediamtx.org/docs/usage/read), and the default stream names are `main` for the main one and `lores` for the low-resolution one (intended for object detection use).

## Case

The case for the camera is designed for 3D printing in several pieces. The OpenSCAD source for the 3D files is in this repository, but a more convenient option for printing is the [Printables page](https://www.printables.com/model/1424686-raspberry-pi-hq-security-camera-mk1) with downloads for all the parts as separate STL files.

- **Internal frame**: The Pi and the camera module mount to this on opposite sides with M2.5 screws.
- **Pi Spacer Shim**: The camera module side of the frame has spacers built in, but I couldn't reasonably do that on both sides. This piece holds the Pi circuit board a few millimeters off the frame so there's room for airflow behind the board.
- **Bottom Shell**: The bottom of the outer shell that the frame slots into.
- **Top Shell**: The top of the outer shell which slides on over the frame.
- **I/O Shields**: Inserts which can go into the openings in the shells and neatly cover everything but the ports on the Pi for easy access.

A few fasteners are required to put everything together:

- M2.5 hex nut x10
- M2.5 screws, 10mm long, x8 for attaching the Pi and camera to the frame.
- M2.5 screws, CSK, x2 for keeping the case shell closed (I used 10mm screws here too because that's what I had handy, but shorter ones would be better).

Assembly instructions:

1. Print all parts. A layer height of 0.2mm for the frame is important so the plate-facing holes print properly.
2. Prepare the Pi with an OS at the very least, although it's smart to do the full software setup and make sure everything works.
3. Insert nuts into all the recesses in the frame, either by pressing or doing screw pulls.
4. Mount camera module to frame.
5. Mount Pi to frame with the spacer shim under it.
6. Insert nuts into the 2 recesses on the sides of the bottom shell piece.
7. Push I/O shields onto the ports of the Pi.
8. Slide the frame into the bottom shell piece.
9. Wrestle any excess camera cable into submission.
10. Slide the top shell piece on over the frame. The tabs on the sides should line up with the indents on the sides of the bottom piece.
11. Secure the shell pieces together with the countersunk screws.

## Background

Years ago, I tried to do something a little similar with a Pi Zero W running motionEyeOS (RIP) with a standard camera module attached. I ran into intermittent network issues which I tracked down to an incompatibility between the radios on the Zero and my Wi-Fi access point. Every once in a while, the Zero would drop off the network and only a reboot would bring it back online, which is rather counterproductive for a device that needs to be reliable 24/7.

I read recently about Frigate and its capabilities, and that inspired me to try to create a security camera that doesn't do any processing or storage onboard beyond encoding and streaming. A server elsewhere on the network could just read the stream and do all the other tasks on a beefier processor. I already had an extra Raspberry Pi 3B+ and an HQ camera module from a previous project, so I put those together and started tinkering. My goal was to have a self-contained unit with minimal software that could stream video to another machine on the network.

## Resources

I couldn't have done this without all the documentation out there:

- Raspberry Pi mechanical drawings: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#schematics-and-mechanical-drawings
- Camera module mechanical drawings:https://www.raspberrypi.com/documentation/accessories/camera.html#mechanical-drawings
- PiCamera2 development guide: https://datasheets.raspberrypi.com/camera/picamera2-manual.pdf
- Examples for using the `picamera2` library: https://github.com/raspberrypi/picamera2/tree/main/examples
- MediaMTX setup options: https://james-batchelor.com/index.php/2023/11/10/install-mediamtx-on-raspbian-bookworm/
- Starting MediaMTX on boot (official docs): https://mediamtx.org/docs/usage/start-on-boot
- Advanced setup options including multiple streams: https://www.wtip.net/blog/2023/07/picamera2-rtsp-streaming-with-multiple-resolution-feeds/

## Known Issues

This design is far from perfect and I plan to take what I've learned here and design an even better _Mk2_ in the future. These are some of the things I want to improve on:

- The seam between the top and bottom halves of the shell is visible, kind of ugly, and difficult to close tightly.
- It can be tough to find a place to stow longer ribbon cables without risking them coming in contact with the hotspots on the Pi.
- Ventilation is not great even with the slots and the Pi gets a little toasty when running its streams.
- The I/O shields aren't as secure as they could be in their cutouts.
- Upward-facing ports could pose a longevity issue as dust settles into them.
- The Pi spacer shim bumped into the slot for the internal frame at one point during prototyping, and my hacky solution to avoid reprinting and re-assembling more parts was to cut away a section of the slot for the shim to rest in.
- Accessing the microSD card slot is not easy. Tweezers are recommended, but they shouldn't have to be.
- Video stream dimensions are hardcoded.
- Settings in general are not customizable.

A fully re-imagined case design is on my agenda, with improvements all around and more modularity. I also want to add more flexibility to the software, with independent `main` and `lores` streams, customizable settings including video resolutions and bitrates, and a UI to interact with.
