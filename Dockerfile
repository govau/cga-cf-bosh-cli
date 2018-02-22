FROM ubuntu:16.04

# Install base packages, ansible, nodejs
RUN apt-get update && apt-get -y install \
        awscli \
        curl \
        dnsutils \
        gcc \
        git \
        jq \
        software-properties-common \
        unzip \
        wget && \
    apt-add-repository ppa:ansible/ansible && \
    apt-get update && apt-get -y install \
        ansible && \
    bash -o pipefail -c "curl -L https://deb.nodesource.com/setup_6.x | bash" && \
    apt-get -y install \
        nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install bosh-cli
RUN curl -L https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.48-linux-amd64 > /usr/local/bin/bosh && \
    chmod a+x /usr/local/bin/bosh

# Install credhub-cli
RUN bash -o pipefail -c "curl -L https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/1.6.0/credhub-linux-1.6.0.tgz | tar -xz -C /usr/local/bin"

# Install go
RUN bash -o pipefail -c "curl -L https://storage.googleapis.com/golang/go1.9.4.linux-amd64.tar.gz | tar -xz -C /usr/local"

# Set Go environment variables
ENV GOROOT=/usr/local/go GOPATH=/go PATH=/go/bin:/usr/local/go/bin:$PATH

# Install glide
RUN mkdir -p /go/bin && \
    bash -o pipefail -c "curl https://glide.sh/get | sh"

# Install go tools
RUN go get \
        github.com/golang/dep/cmd/dep \
        github.com/GeertJohan/fgt \
        github.com/golang/lint/golint \
        github.com/govau/sdget \
        github.com/jteeuwen/go-bindata/... \
        golang.org/x/tools/cmd/cover

# Install common NPM stuff, and:
# Fix bug https://github.com/npm/npm/issues/9863
RUN cd $(npm root -g)/npm && \
    npm install fs-extra && \
    sed -i -e s/graceful-fs/fs-extra/ -e s/fs\.rename/fs.move/ ./lib/utils/rename.js && \
    npm install -g yarn

# Install terraform
RUN curl -L https://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip > /tmp/terraform.zip && \
    unzip /tmp/terraform.zip terraform -d /usr/local/bin && \
    rm /tmp/terraform.zip
