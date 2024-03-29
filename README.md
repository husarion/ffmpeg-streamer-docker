# ffmpeg-streamer-docker

FFMPEG image encoder/decoder with best effor QoS optimized for video streaming.

## Qucick start

### Running encoder

#### CPU

`compose.yaml`:

```yaml
services:
  ffmpeg_compressor:
    image: husarion/ffmpeg-streamer:humble-1.0.0-20240329
    environment:
      - TYPE=ENCODER
      - RAW_TOPIC=/image_raw
      - FFMPEG_TOPIC=/image_raw/ffmpeg_best_effort

  ffmpeg_decompressor:
    image: husarion/ffmpeg-streamer:humble-1.0.0-20240329
    environment:
      - TYPE=DECODER
      - RAW_TOPIC=/image_raw/ffmpeg_decompressed
      - FFMPEG_TOPIC=/image_raw/ffmpeg_best_effort
```

#### NVIDIA GPU

Create `params.yaml` file for FFMPEG.

To find available encoders:

```bash
ffmpeg -encoders
```

To list available presets:

```bash
ffmpeg -h encoder=hevc_nvenc # hevc_nvenc is nvidia hardware encoder
```

`params.yaml` file may look like that

```yaml
---
/image_republisher:
  ros__parameters:
    ffmpeg_image_transport:
      encoding: hevc_nvenc
      preset: llhp
      tune: ll
```

`compose.yaml`:

```yaml
services:
  ffmpeg_compressor:
    image: husarion/ffmpeg-streamer:humble-1.0.0-20240329
    runtime: nvidia
    volumes:
     - ./params.yaml:/params.yaml
    environment:
      - TYPE=ENCODER
      - RAW_TOPIC=/image_raw
      - FFMPEG_TOPIC=/image_raw/ffmpeg_best_effort
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all

  ffmpeg_decompressor:
    image: husarion/ffmpeg-streamer:humble-1.0.0-20240329
    runtime: nvidia
    volumes:
     - ./params.yaml:/params.yaml
    environment:
      - TYPE=DECODER
      - RAW_TOPIC=/image_raw/ffmpeg_decompressed
      - FFMPEG_TOPIC=/image_raw/ffmpeg_best_effort
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
```