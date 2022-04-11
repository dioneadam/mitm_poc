# Man in the Middle POC

## Setup

There are 3 containers, Server, Client and The_mitm.

- **Server**: is hosting an http server, serving the files contained in `server_files`
- **Client**: is a container with Firefox running on it. To connect to firefox from the host, visit `http://localhost:5800`.
- **The_mitm**: is a container meant to be used via bash. To run commands, just run `docker exec -it the_mitm /bin/bash`. This container has the `mitm_files` folder mounted on the container as `/proxy_files`

The three containers are connected together with a docker bridge network called `mitm`

## How to run

1. Install Docker, docker-compose, then run `docker-compose up -d`
2. Connect to client's Firefox instance and visit `http://website/`. This should show the actual website of the server
4. Open 2 instances of bash on the_mitm container and run `dig` to discover the IPs of server and client:

```
$ dig server
$ dig client
```

5. With this information, now run arspoof:

In the first bash window:
```
$ arpspoof -t <client_ip> <server_ip>
```
```
$ arpspoof -t <server_ip> <client_ip>
```

6. Now to the client, the server's IP is now associated to the_mitm MAC address, meaning that the ARP spoofing was successful. In any case, reloading the page still shows the normal website, since the_mitm is not blocking any packets yet.
7. You can disable the ip_forward on the_mitm just to check this. just run: 
```
echo 0 > /proc/sys/net/ipv4/ip_forward 
```
and try access the website again. You should get a error. After that, `set 1 to ip_forward` to continue.

7. Now run the `add_iptables_rule.sh` script in the `proxy_files` folder. This will add a rule to `iptables` to forward every packet with destination port 80 to the proxy
8. You may verify that client's browser will give an error when reloading the page. This is because the_mitm is not blocking the packets in pitables and forwarding them to the proxy. Since the proxy is not active yet, the packets are simply dropped.
9. Now we activate the proxy in passive mode:

```
mitmproxy -m transparent
```

10. Reload the browser page: the page will show again, but mitmproxy will show that the request passed through Eve
11. Now shut down the proxy and activate it again, this time with the script that modifies the contents of the page:
```
mitmproxy -m transparent -s /proxy_files/proxy.py
```
12. Reload the browser page: the attacker has changed the contents of the website.
13. To shut down everything use the `del_iptables_rul.sh` script to remove the iptables rule and turn off the two arpspoof instances
14. You can also monitoring the packets with wireshark, just run `termshark`
