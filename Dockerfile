# Stage 1: Base image with common dependencies
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1

RUN mkdir /app
WORKDIR /app

# # Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Clone comfyui-worker repository
RUN git clone https://github.com/mertguvencli/comfyui-worker /worker

WORKDIR /worker

# Install worker dependencies
RUN pip3 install --upgrade --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install --upgrade -r requirements.txt

# Install Custom Nodes
RUN python3 install_custom_nodes.py

# Install ComfyUI Manager & Custom Node's Dependencies
RUN chmod +x install_manager.sh
RUN install_manager.sh

WORKDIR /app

# Install runpod
RUN pip3 install runpod requests

# Support for the network volume
ADD extra_model_paths.yaml ./worker/ComfyUI/

# Start the container
COPY . .

RUN chmod +x start.sh
CMD start.sh
