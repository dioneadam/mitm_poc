FROM ubuntu

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y iptables tcpdump dsniff iproute2 python3 python3-pip tmux dnsutils
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark termshark
RUN pip3 install scapy mitmproxy

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
