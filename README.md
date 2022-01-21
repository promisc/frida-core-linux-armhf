# frida-core-linux-armhf

Using the image from https://github.com/promisc/frida-toolchain-linux-armhf, build frida core components (i.e. run `make core-linux-armhf`).

At the moment the image produced only contains a few Frida components (`frida-gadget.so`, `frida-inject` and `frida-server`). These are available in the publish packages as docker images e.g. `docker pull ghcr.io/promisc/frida-core-linux-armhf:5b9d256f-glibc_2_17`.

## Todo
* Add frida tests
* Run tests in qemu-system
