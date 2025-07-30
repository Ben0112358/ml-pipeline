FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    software-properties-common \
    gnupg \
    curl \
    git \
    unzip \
    docker.io \
    python3 \
    python3-pip \
    ca-certificates

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN apt-get update && apt-get install -y jq


RUN curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

    
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && apt-get install -y terraform && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

ENV ML_HOMELAB_ROOT=/ml-homelab
ENV ML_WORKSPACE_ROOT=/ml_workspace_root

RUN chmod +x /app/*.sh

ENTRYPOINT ["./pipeline.sh"]
