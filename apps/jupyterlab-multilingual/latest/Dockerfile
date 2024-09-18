FROM jupyter/base-notebook as builder

USER root
ENV USER_HOME /home/jovyan

RUN sed -i 's|http://ports.ubuntu.com/ubuntu-ports/|http://mirrors.aliyun.com/ubuntu-ports/|g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl unzip build-essential git && \
    curl -Ls https://sh.jbang.dev | bash -s - app setup

RUN mkdir $USER_HOME/.local && mkdir $USER_HOME/.local/share && chmod -R 777 $USER_HOME/.local/share

ENV PATH $USER_HOME/.local/bin:$PATH

# 安装 Mise Demo、Rust、Go
RUN curl https://mise.run | sh

RUN mise use --global deno@latest
# RUN mise use --global go@latest
# RUN git clone https://github.com/code-lever/asdf-rust $USER_HOME/.local/share/mise/plugins/rust
# RUN mise use --global rust@latest
RUN mise install
RUN rm -rf $USER_HOME/.local/share/mise/downloads

# 安装 Deno 和 Deno Kernel
ENV PATH $USER_HOME/.local/share/mise/installs/deno/latest/bin:$PATH
RUN deno jupyter --install && \
    chmod -R 777 $USER_HOME/.local/share/jupyter && \
    rm -f $USER_HOME/install.py

# 安装 C++ 和 C 语言的 Jupyter Kernel
# RUN pip install xeus-cling
RUN pip install jupyter-cpp-kernel

# 安装 Java 和 Java Kernel
RUN curl -Ls https://sh.jbang.dev | bash -s - app setup

# 安装 Go 和 Go Kernel
# ENV PATH $USER_HOME/.local/share/mise/installs/go/latest/bin:$USER_HOME/go/bin:$PATH
# RUN go install github.com/janpfeifer/gonb@latest && \
#     go install golang.org/x/tools/cmd/goimports@latest && \
#     go install golang.org/x/tools/gopls@latest && \
#     gonb --install
# RUN chmod -R 777 $USER_HOME/.cache/go-build && rm -rf $USER_HOME/.cache/go-build
# RUN chmod -R 777 $USER_HOME/go/pkg/mod && rm -rf $USER_HOME/go/pkg/mod

# 安装 Rust 和 Rust Kernel
# ENV PATH $USER_HOME/.local/share/mise/installs/rust/latest/bin:$PATH
# RUN cargo install evcxr_jupyter && \
#     $USER_HOME/.cargo/bin/evcxr_jupyter --install

# 升级 jupyter
RUN pip install --upgrade pip && \
    pip install --upgrade jupyter jupyterlab notebook

# 清理步骤
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV PATH $USER_HOME/.jbang/bin:$PATH

# 赋予用户权限
RUN chmod -R 777 $USER_HOME/.config/mise && \
    chmod -R 777 $USER_HOME/.local/share/mise && \
    chmod -R 777 $USER_HOME/.jbang && \
    chmod -R 777 $USER_HOME/.cache

USER jovyan

RUN jbang trust add https://github.com/jupyter-java/ && \
    # jbang install-kernel@jupyter-java ijava && \
    jbang install-kernel@jupyter-java rapaio && \
    jbang install-kernel@jupyter-java kotlin

RUN rm -rf $USER_HOME/.jbang/cache

# 第二阶段，仅复制必要文件到新的基础镜像
FROM jupyter/base-notebook

COPY --from=builder /home/jovyan /home/jovyan
COPY --from=builder /usr/local /usr/local
COPY --from=builder /opt/conda/share/jupyter/kernels /opt/conda/share/jupyter/kernels

# Mise Path
ENV PATH /home/jovyan/.local/bin:$PATH

# Java Path
ENV PATH /home/jovyan/.jbang/bin:$PATH

# Deno Path
ENV PATH /home/jovyan/.deno/bin::$PATH
ENV PATH /home/jovyan/.local/share/mise/installs/deno/latest/bin:$PATH

# # Go Path
# ENV PATH /home/jovyan/.local/share/mise/installs/go/latest/bin:$PATH
# ENV PATH /home/jovyan/go/bin:$PATH

# Rust Path
# ENV PATH /home/jovyan/.local/share/mise/installs/rust/latest/bin:$PATH

USER jovyan

# 安装 JupyterLab 插件
RUN chmod -R 777 /home/jovyan/work && \
    pip install jupyterlab-unfold && \
    pip install jupyterlab_code_formatter
