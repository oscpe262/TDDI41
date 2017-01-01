$TTL	3600
@	IN	SOA	server.oscpe.bot.nu.	HOSTMASTER.oscpe.bot.nu. (
		2	; Serial
		3600		; Refresh
		600		; Retry
		86400		; Expire
		600		; Negative Cache TLL
);

; name servers - NS records
	IN	NS	server.oscpe.bot.nu.

; 192.168.122.10/28 - A records
server.oscpe.bot.nu.	IN	A	192.168.122.11
gw.oscpe.bot.nu.	IN	A	192.168.122.10
client-1.oscpe.bot.nu.	IN	A	192.168.122.12
client-2.oscpe.bot.nu.	IN	A	192.168.122.13
