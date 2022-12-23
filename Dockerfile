# syntax=docker/dockerfile:1

FROM python:latest AS builder
RUN git clone --recursive https://github.com/Coldcard/firmware.git
RUN apt update
RUN apt install -y build-essential git python3 python3-pip libudev-dev gcc-arm-none-eabi libffi-dev xterm swig libpcsclite-dev python-is-python3 libsdl2-2.0-0
WORKDIR /firmware
# apply address patch
RUN git apply unix/linux_addr.patch
# create virtualenv and use it
ENV VIRTUAL_ENV=/firmware/ENV
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
# install dependencies
RUN pip install -U pip setuptools
RUN pip install -r requirements.txt
# mpy-cross
WORKDIR /firmware/external/micropython/mpy-cross/
RUN make
WORKDIR /firmware/unix
# build simulator
RUN make setup
RUN make ngu-setup
RUN make

FROM python:3.7.16-slim-bullseye

COPY --from=builder /firmware/ENV /firmware/ENV
COPY --from=builder /firmware/unix /firmware/unix
COPY --from=builder /firmware/shared /firmware/shared
COPY --from=builder /firmware/external/micropython/ports/unix /firmware/external/micropython/ports/unix
COPY --from=builder /firmware/external/ckcc-protocol /firmware/external/ckcc-protocol
COPY --from=builder /firmware/graphics /firmware/graphics
COPY --from=builder /firmware/stm32 /firmware/stm32

RUN apt-get update && apt-get install --no-install-recommends -y xterm libsdl2-2.0-0 && rm -rf /var/lib/apt/lists

ENV VIRTUAL_ENV=/firmware/ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python -m ensurepip && pip install pysdl2-dll pysdl2 pillow "ckcc-protocol[cli]"
RUN echo "alias ckcc='ckcc -x'" >> /root/.bashrc

WORKDIR /firmware/unix
ENV DISPLAY=:0
VOLUME [ "/tmp/.X11-unix" ]
CMD ["./simulator.py"]
