# Docker image for rk3506 Linux SDK build environment

## Usage

```bash
> docker pull ghcr.io/jiu-xiao/rk3506_image_builder

> docker run --rm -it \
  --name rk3506-build \
  --user $(id -u):$(id -g) \
  -e LANG=C.UTF-8 -e LC_ALL=C.UTF-8 \
  -v ~/your_source_code/rk3506_linux6.1_sdk20241216:/work/rk3506_linux6.1_sdk \
  -v ~/.ccache:/home/dev/.ccache \
  -w /work/rk3506_linux6.1_sdk \
  ghcr.io/jiu-xiao/rk3506_image_builder:master
```
