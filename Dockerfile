# Use an NVIDIA CUDA base image with CUDA 12.2 and cuDNN installed
FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu20.04

ENV NB_USER="gpuuser"
ENV UID=999
ENV DEBIAN_FRONTEND noninteractive

# Update system and install basic dependencies
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    git \
    ca-certificates \
    locales \
    sudo \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Add deadsnakes PPA and install Python 3.9
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt install -y python3.9 python3.9-dev python3-pip

# Update alternatives to use Python 3.9
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Upgrade pip and install essential Python packages
RUN python3.9 -m pip install --upgrade pip

# Set SSL certificates environment variable
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# Update PATH
ENV PATH=/usr/bin/python3.9:$PATH

# Set environment variables for user configuration
ENV SHELL=/bin/bash \
    NB_USER="${NB_USER}" \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    HOME="/home/${NB_USER}"

USER root

# User and permissions setup
RUN useradd -l -m -s /bin/bash -u $UID $NB_USER && \
    echo "$NB_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ${NB_USER}

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -f -b -p /opt/conda && rm -rf ~/miniconda.sh

# Install Mamba and essential libraries
RUN /opt/conda/bin/conda install -c conda-forge mamba python==3.9 && \
    /opt/conda/bin/mamba install -c conda-forge jupyterlab jupyter-resource-usage && \
    /opt/conda/bin/mamba clean --all --yes

# Install PyTorch and Transformers
RUN /opt/conda/bin/mamba install -c conda-forge pytorch torchvision torchaudio cudatoolkit=12.2 -c pytorch && \
    /opt/conda/bin/pip install transformers

# Configure JupyterLab to use SSL
RUN mkdir -p /home/${NB_USER}/.jupyter
COPY jupyter_lab_config.py /home/${NB_USER}/.jupyter/

# Copy the SSL certificates
COPY mycert.pem /home/${NB_USER}/.jupyter/
COPY mykey.key /home/${NB_USER}/.jupyter/

# Copy the startup script
COPY startup.sh /home/${NB_USER}/startup.sh
RUN chmod +x /home/${NB_USER}/startup.sh

# Expose port and set CMD to launch startup script
EXPOSE 8888
CMD ["/home/gpuuser/startup.sh"]
