FROM bitnami/minideb
RUN apt update; apt install -y sudo; \
	apt-get autoremove -y && \
	devu=test && adduser --gecos "" --disabled-password $devu && chpasswd <<<"$devu:$devu" && adduser $devu sudo && \
	su $devu -c "sudo -S apt install -y wget <<<$devu && cd /home/$devu && wget https://raw.githubusercontent.com/snieda/termos/main/termos.sh && . termos.sh" && \
	rm -rf /var/lib/apt/lists/*
