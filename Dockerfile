FROM ubuntu:focal@sha256:fd92c36d3cb9b1d027c4d2a72c6bf0125da82425fc2ca37c414d4f010180dc19

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends ca-certificates openssl wget curl unzip sudo adduser less git pkg-config \
    && groupadd --gid 1000 ubuntu \
    && useradd --uid 1000 --gid 1000 -m ubuntu \
    && echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

RUN wget https://storage.googleapis.com/kubernetes-release/release/$(wget https://storage.googleapis.com/kubernetes-release/release/stable.txt -q -O -)/bin/linux/amd64/kubectl -q -O /usr/local/bin/kubectl \
    && chmod a+x /usr/local/bin/kubectl \
    && mkdir /home/ubuntu/.kube \
    && chmod g+rwX /home/ubuntu/.kube \
    && kubectl

RUN wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -q -O awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && aws --version

RUN wget https://get.helm.sh/helm-canary-linux-amd64.tar.gz -q -O helm.tar.gz \
    && tar -xzvf helm.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && helm version

RUN wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -q -O /usr/local/bin/kubectx \
    && chmod +x /usr/local/bin/kubectx \
    && wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -q -O /usr/local/bin/kubens \
    && chmod +x /usr/local/bin/kubens

RUN wget https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64 -q -O /usr/local/bin/kind \
    && chmod +x /usr/local/bin/kind \
    && wget https://get.docker.com -o get-docker.sh -q -O get-docker.sh \
    && sh ./get-docker.sh \
    && usermod -aG docker ubuntu

RUN wget https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz -q -O krew.tar.gz \
    && tar -xzvf krew.tar.gz

USER ubuntu
WORKDIR /home/ubuntu

RUN /krew-linux_amd64 install krew \
    && echo 'export PATH="$HOME/.krew/bin:$PATH"' >> ~/.bashrc \
    && export PATH="$HOME/.krew/bin:$PATH" \
    && kubectl krew update \
    && kubectl krew install exec-as modify-secret view-secret whoami

CMD ["/bin/bash"]
