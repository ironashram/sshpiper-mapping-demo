use sshpiper;

update downstreams set password = 'onepass', auth_map_type = 1 where username = 'one_user';
insert into keydata (name, data, type)
values ('mykey','ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvba45qMCjSoQW4en67Ai1Zj5cUzi6VuBii53no9tqM test@example.com','publickey');
insert into keydata (name, data, type)
values ('myprivatekey','-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACC722uOajAo0qEFuHp+uwItWY+XFM4ulbgYoud56PbajAAAAJh53uS4ed7k
uAAAAAtzc2gtZWQyNTUxOQAAACC722uOajAo0qEFuHp+uwItWY+XFM4ulbgYoud56PbajA
AAAEDsNEJh2jyz/C1zxDYUXdVNBO2TCG72XSgIx0qOsA2+0rvba45qMCjSoQW4en67Ai1Z
j5cUzi6VuBii53no9tqMAAAAEHRlc3RAZXhhbXBsZS5jb20BAgMEBQ==
-----END OPENSSH PRIVATE KEY-----','privatekey');
insert into upstream_authorized_keys (key_id,downstream_id) values ((select id from keydata where name = 'mykey'),(select id from downstreams where username = 'one_user'));
insert into upstream_private_keys (key_id,upstream_id) values ((select id from keydata where name = 'myprivatekey'),(select id from upstreams where username = 'different_user'));
update upstreams set private_key_id = (select id from keydata where name = 'myprivatekey'), auth_map_type = 2 where username = 'different_user';
