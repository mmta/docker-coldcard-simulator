# Docker for Coldcard simulator

This is a docker image for [Coldcard wallet simulator](https://github.com/Coldcard/firmware). Image size is around 400MB, pretty big but better than keeping the 8GB left-over files from building it from the repo.

## Quick start

There's pre-built image on [Dockerhub](https://hub.docker.com/repository/docker/mmta/coldcard-simulator). You need to have an X server running where the docker host is, and then:

```
$ docker run --rm -it --name coldcard \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd)/coldcard-settings:/firmware/unix/work/settings \
    mmta/coldcard-simulator
```
The first `-v` is for X server connection, and the second one is for persisting configuration changes.

This should just works out of the box if you're using Linux. Windows 10/11 users will need to install 
[Windows Subsystem for Linux (WSL)](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R), and Windows 10 will also need the appropriate OS updates to support [WSLg](https://github.com/microsoft/wslg). Screenshot of the simulator running on WSL2 (Ubuntu):

![coldcard simulator](examples/screenshot.png)

## Command lines

Refer to Coinkite's [guide](https://github.com/Coldcard/firmware/tree/master/unix) for available startup options. For example, to start from factory-fresh condition you can run:

```
$ docker run --rm -it --name coldcard \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd)/coldcard-settings:/firmware/unix/work/settings \
    mmta/coldcard-simulator \
    ./simulator.py -w
```

The image also include Coldcard command line utility `ckcc`. For instance, to get a receiving address from the simulator, open another terminal while the simulator is running and execute:

```
$ docker exec -it coldcard ckcc -x addr -s
Displaying address:

tb1qsy79s7h7lh2m0mpytzy2fpj4unuusp4hnjhq4k
```
`ckcc` can upload PSBT file for signing, entering your BIP39 passphrase, and [a lot more](https://github.com/Coldcard/ckcc-protocol).
## Security warning

There is an option to use Mainnet (the default is to run on Testnet), and that can be persisted to the `settings` directory as shown above.

Files in there are encrypted, but that doesn't mean it's OK to use this simulator for Mainnet. The real Coldcard has secure elements to store and process secrets while the simulator obviously has none.