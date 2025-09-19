# 基础镜像：Ubuntu 22.04（与你现有主机环境一致）
FROM ubuntu:22.04

# 1) 基础环境与常用工具
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Singapore \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    # 编译基础
    build-essential python2 python-is-python3 sudo \
    gcc g++ libgmp-dev libmpc-dev \
    make cmake nano expect expect-dev bsdmainutils \
    ccache iputils-ping cpio openssh-client fakeroot \
    # 版本与工具
    git curl wget unzip zip rsync gawk scons \
    # Python（Buildroot/脚本常用）
    python3 python3-pip python3-venv \
    # 设备树/内核等依赖
    device-tree-compiler \
    bc bison flex \
    libssl-dev \
    libncurses5-dev libncursesw5-dev \
    libelf-dev \
    dwarves \
    # 压缩&镜像工具
    lz4 xz-utils zstd lzop \
    # 其他常用
    file ca-certificates \
    # repo 工具依赖（如使用 manifest 同步源码）
    gnupg \
  && rm -rf /var/lib/apt/lists/*

# 可选：安装 repo（如果你用 manifest 同步 SDK 源码）
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
  && chmod +x /usr/local/bin/repo

# 2) 创建非 root 用户，避免宿主机文件权限问题（可用构建参数自定义 UID/GID）
ARG USERNAME=dev
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USERNAME} \
  && useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USERNAME} \
  && mkdir -p /work && chown -R ${USERNAME}:${USERNAME} /work \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USERNAME}
WORKDIR /work

# 3) ccache & 常用环境变量（可选）
ENV CCACHE_DIR=/home/${USERNAME}/.ccache \
    CCACHE_MAXSIZE=10G \
    CCACHE_COMPRESS=1 \
    # 避免 git “detected dubious ownership” 报错
    GIT_CEILING_DIRECTORIES=/work

# 4) 质量：展示工具版本，便于排错（构建时打印到日志）
RUN echo "==== Tool Versions ====" \
 && echo -n "python3: " && python3 --version \
 && echo -n "make:    " && make -v | head -n1 \
 && echo -n "lz4:     " && lz4 -v | head -n1 \
 && echo -n "dtc:     " && dtc --version || true \
 && echo -n "gcc:     " && gcc --version | head -n1 \
 && echo "======================="

# 5) 可选：把 /work 设为安全目录，避免 git 权限告警
RUN git config --global --add safe.directory /work \
 && git config --global --add safe.directory /work/rk3506_linux6.1_sdk || true

# 6) 默认入口：启动交互 shell（你会挂载源码进 /work）
CMD ["/bin/bash"]
