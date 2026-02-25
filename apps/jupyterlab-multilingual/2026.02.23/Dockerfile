# ============================================
# 多语言 Jupyter Notebook Dockerfile
# 支持语言: Python, Java, Kotlin, JavaScript, TypeScript, Rust, Go
# ============================================
#
# 构建示例:
#   全部启用（默认）:
#     docker build -t jupyter-full .
#
#   只启用 Python + JS/TS:
#     docker build -t jupyter-lite \
#       --build-arg ENABLE_RUST=false \
#       --build-arg ENABLE_GO=false \
#       --build-arg ENABLE_JAVA=false .
#
#   只启用 Python + Rust + Go:
#     docker build -t jupyter-systems \
#       --build-arg ENABLE_DENO=false \
#       --build-arg ENABLE_JAVA=false .
#
# ============================================

# ============================================
# 构建参数 - 设置为 true/false 来启用/禁用各语言
# ============================================
ARG ENABLE_DENO=true
ARG ENABLE_RUST=true
ARG ENABLE_GO=true
ARG ENABLE_JAVA=true

# 第一阶段：构建
FROM quay.io/jupyter/base-notebook:2026-02-23 as builder

# 传递 ARG 到构建阶段
ARG ENABLE_DENO
ARG ENABLE_RUST
ARG ENABLE_GO
ARG ENABLE_JAVA

USER root
ENV USER_HOME=/home/jovyan
ENV DEBIAN_FRONTEND=noninteractive

# 将 ARG 保存为环境变量（供后续 RUN 使用）
ENV ENABLE_DENO=${ENABLE_DENO}
ENV ENABLE_RUST=${ENABLE_RUST}
ENV ENABLE_GO=${ENABLE_GO}
ENV ENABLE_JAVA=${ENABLE_JAVA}

# 国内镜像加速（如不需要可删除这段）
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || \
    sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list 2>/dev/null || true

# 安装构建依赖（根据启用的语言动态安装）
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    && if [ "$ENABLE_RUST" = "true" ]; then \
        apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libssl-dev \
        cmake; \
    fi \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 切换用户安装 kernel
USER jovyan

# ============================================
# 安装 Mise（现代版本管理器）
# 统一管理 Deno, Rust, Go 等运行时
# ============================================
ENV PATH=$USER_HOME/.local/bin:$PATH
RUN curl https://mise.run | sh

# ============================================
# 安装 Deno（用于 JS/TS Kernel）
# Deno 内置 Jupyter kernel，原生支持 TypeScript
# ============================================
RUN if [ "$ENABLE_DENO" = "true" ]; then \
        mise use --global deno@latest && mise install && \
        export PATH=$USER_HOME/.local/share/mise/installs/deno/latest/bin:$PATH && \
        deno jupyter --install; \
    fi
ENV PATH=$USER_HOME/.local/share/mise/installs/deno/latest/bin:$PATH

# ============================================
# 安装 Rust（用于 evcxr Kernel）
# evcxr 是目前唯一活跃维护的 Rust Jupyter kernel
# ============================================
ENV CARGO_HOME=$USER_HOME/.cargo
ENV RUSTUP_HOME=$USER_HOME/.rustup

RUN mkdir -p $CARGO_HOME $RUSTUP_HOME

RUN if [ "$ENABLE_RUST" = "true" ]; then \
        mise use --global rust@latest && mise install && \
        export PATH=$USER_HOME/.cargo/bin:$PATH && \
        cargo install --locked evcxr_jupyter && \
        evcxr_jupyter --install; \
    fi

ENV PATH=$USER_HOME/.cargo/bin:$PATH

# ============================================
# 安装 Go（用于 GoNB Kernel）
# GoNB 使用标准 Go 编译器，支持 CGO 和 auto-complete
# ============================================
ENV GOPATH=$USER_HOME/go
RUN if [ "$ENABLE_GO" = "true" ]; then \
        mise use --global go@latest && mise install && \
        export PATH=$USER_HOME/.local/share/mise/installs/go/latest/bin:$PATH && \
        export PATH=$GOPATH/bin:$PATH && \
        go install github.com/janpfeifer/gonb@latest && \
        go install golang.org/x/tools/cmd/goimports@latest && \
        go install golang.org/x/tools/gopls@latest && \
        gonb --install; \
    fi
ENV PATH=$USER_HOME/.local/share/mise/installs/go/latest/bin:$PATH
ENV PATH=$GOPATH/bin:$PATH

# ============================================
# 安装 JBang（用于 Java/Kotlin Kernel）
# jupyter-java 组织提供的统一安装方案
# ============================================
RUN if [ "$ENABLE_JAVA" = "true" ]; then \
        curl -Ls https://sh.jbang.dev | bash -s - app setup; \
    fi
ENV PATH=$USER_HOME/.jbang/bin:$PATH

# 安装 Java 和 Kotlin kernel
# - rapaio: 功能完整的 Java kernel，活跃维护
# - kotlin: Kotlin kernel
RUN if [ "$ENABLE_JAVA" = "true" ]; then \
        jbang trust add https://github.com/jupyter-java/ && \
        jbang install-kernel@jupyter-java rapaio && \
        jbang install-kernel@jupyter-java kotlin; \
    fi

# ============================================
# 清理缓存（重要！减少镜像大小）
# ============================================
USER root

# 清理 Mise 下载缓存
RUN rm -rf $USER_HOME/.local/share/mise/downloads

# 清理 Cargo 缓存（保留 bin，删除编译缓存）
RUN if [ "$ENABLE_RUST" = "true" ]; then \
        rm -rf $USER_HOME/.cargo/registry/cache \
        $USER_HOME/.cargo/registry/src \
        $USER_HOME/.cargo/git; \
    fi

# 清理 Go 缓存
RUN if [ "$ENABLE_GO" = "true" ]; then \
        rm -rf $USER_HOME/.cache/go-build \
        $GOPATH/pkg/mod/cache; \
    fi

# 清理 JBang 缓存
RUN if [ "$ENABLE_JAVA" = "true" ]; then \
        rm -rf $USER_HOME/.jbang/cache; \
    fi

# 清理其他缓存
RUN rm -rf $USER_HOME/.cache/* /tmp/*

# 确保所有目录存在（即使为空），避免 COPY 失败
RUN mkdir -p $USER_HOME/.deno \
    $USER_HOME/.cargo \
    $USER_HOME/go \
    $USER_HOME/.jbang

RUN chown -R jovyan:users $USER_HOME

# ============================================
# 第二阶段：最终镜像
# ============================================
FROM jupyter/base-notebook:latest

# 传递 ARG 到第二阶段
ARG ENABLE_DENO
ARG ENABLE_RUST
ARG ENABLE_GO
ARG ENABLE_JAVA

USER root
ENV USER_HOME=/home/jovyan
ENV DEBIAN_FRONTEND=noninteractive

# 将 ARG 保存为环境变量
ENV ENABLE_DENO=${ENABLE_DENO}
ENV ENABLE_RUST=${ENABLE_RUST}
ENV ENABLE_GO=${ENABLE_GO}
ENV ENABLE_JAVA=${ENABLE_JAVA}

# 国内镜像加速
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || \
    sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' /etc/apt/sources.list 2>/dev/null || true

# 安装运行时依赖（根据启用的语言动态安装）
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    git \
    && if [ "$ENABLE_RUST" = "true" ]; then \
        apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libssl-dev; \
    fi \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 从构建阶段复制必要文件
COPY --from=builder --chown=jovyan:users /home/jovyan/.local /home/jovyan/.local
COPY --from=builder --chown=jovyan:users /home/jovyan/.deno /home/jovyan/.deno
COPY --from=builder --chown=jovyan:users /home/jovyan/.cargo /home/jovyan/.cargo
COPY --from=builder --chown=jovyan:users /home/jovyan/go /home/jovyan/go
COPY --from=builder --chown=jovyan:users /home/jovyan/.jbang /home/jovyan/.jbang
COPY --from=builder /opt/conda/share/jupyter/kernels /opt/conda/share/jupyter/kernels

# ============================================
# 环境变量配置
# ============================================
# Mise
ENV PATH=$USER_HOME/.local/bin:$PATH

# Deno
ENV PATH=$USER_HOME/.local/share/mise/installs/deno/latest/bin:$PATH
ENV PATH=$USER_HOME/.deno/bin:$PATH

# Rust
ENV PATH=$USER_HOME/.local/share/mise/installs/rust/latest/bin:$PATH
ENV PATH=$USER_HOME/.cargo/bin:$PATH
ENV CARGO_HOME=$USER_HOME/.cargo

# Go
ENV PATH=$USER_HOME/.local/share/mise/installs/go/latest/bin:$PATH
ENV GOPATH=$USER_HOME/go
ENV PATH=$GOPATH/bin:$PATH

# JBang (Java/Kotlin)
ENV PATH=$USER_HOME/.jbang/bin:$PATH

# ============================================
# 安装 JupyterLab 插件和 Python 工具
# ============================================
USER jovyan

RUN pip install --no-cache-dir \
    # -------- 代码格式化 --------
    jupyterlab_code_formatter \
    black \
    isort \
    # -------- LSP 支持（代码提示、自动补全、跳转定义、诊断）--------
    # jupyterlab-lsp 需要 JupyterLab >= 4.1.0
    jupyterlab-lsp \
    # Python LSP server（包含 pylint, pyflakes, pycodestyle 等）
    'python-lsp-server[all]' \
    # -------- 文件管理增强 --------
    jupyterlab-unfold \
    # -------- Git 集成 --------
    jupyterlab-git \
    # -------- 变量查看器 --------
    lckr-jupyterlab-variableinspector \
    && pip cache purge

# ============================================
# 可选：安装 TypeScript/JavaScript LSP server
# 如果需要更好的 JS/TS 代码提示，取消下面注释
# ============================================
# RUN npm install -g typescript-language-server typescript

# ============================================
# JupyterLab 配置
# ============================================
RUN mkdir -p $USER_HOME/.jupyter/lab/user-settings/@ryantam626/jupyterlab_code_formatter

# 启用保存时自动格式化（Python）
RUN echo '{"formatOnSave": true}' > \
    $USER_HOME/.jupyter/lab/user-settings/@ryantam626/jupyterlab_code_formatter/settings.jupyterlab-settings

WORKDIR /home/jovyan/work
