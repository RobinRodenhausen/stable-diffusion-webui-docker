FROM python:3.11-slim

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends bc git libgl1 libglib2.0-0 libtcmalloc-minimal4 sudo \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 ai \
    && useradd --uid 1000 --gid 1000 --create-home ai

RUN echo 'ai ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/ai \
    && chmod 0440 /etc/sudoers.d/ai

USER ai
WORKDIR /home/ai/stable-diffusion-webui

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git . \
    && mkdir -p /home/ai/stable-diffusion-webui/repositories \
    && git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git /home/ai/stable-diffusion-webui/repositories/stable-diffusion-webui-assets \
    && git clone https://github.com/Stability-AI/stablediffusion.git /home/ai/stable-diffusion-webui/repositories/stable-diffusion-stability-ai \
    && git clone https://github.com/Stability-AI/generative-models.git /home/ai/stable-diffusion-webui/repositories/generative-models \
    && git clone https://github.com/crowsonkb/k-diffusion.git /home/ai/stable-diffusion-webui/repositories/k-diffusion \
    && git clone https://github.com/salesforce/BLIP.git /home/ai/stable-diffusion-webui/repositories/BLIP \
    && git config --global advice.detachedHead false \
    && echo 'export COMMANDLINE_ARGS="--listen"' > webui-user.sh

RUN pip install --upgrade pip \
    && pip install git+https://github.com/openai/CLIP.git open_clip_torch torch torchvision xformers --extra-index-url https://download.pytorch.org/whl/cu124 \
    && pip install -r requirements_versions.txt

ENV venv_dir="-"

CMD ["bash", "webui.sh"]
