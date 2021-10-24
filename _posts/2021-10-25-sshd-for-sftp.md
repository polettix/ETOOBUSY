---
title: Setting up an SFTP server
type: post
tags: [ OpenSSH, security ]
comment: true
date: 2021-10-25 07:00:00 +0200
mathjax: false
published: true
---

**TL;DR**

> I'm interested into the setup of a SFTP-only server.

To make things very, very blunt I'm currently using this configuration
for [OpenSSH][]:

```
Protocol 2
Port     22
ListenAddress 0.0.0.0

UsePAM yes
UseDNS no
PermitRootLogin        no
PubkeyAuthentication   yes
PasswordAuthentication yes
PermitEmptyPasswords   no
ChallengeResponseAuthentication yes

ClientAliveInterval 10
ClientAliveCountMax 6
KeepAlive   no
Compression yes
PrintMotd   no

PermitUserEnvironment no
AllowAgentForwarding  no
AllowTcpForwarding    no
GatewayPorts  no
PermitTunnel  no
GatewayPorts  no
X11Forwarding no

Subsystem       sftp internal-sftp
AllowGroups     sftpreader sftpwriter

Match Group sftpreader
    ForceCommand    internal-sftp
    ChrootDirectory /var/sftp/frozen/%u

Match Group sftpwriter
    ForceCommand    internal-sftp
    ChrootDirectory /var/sftp
```

The idea is that the administrator will rarely get into this machine
and, when needed, the console is sufficient. So no login for root, and
actually for nobody else because of the `AllowGroups` and the two
`Match` directives.

In particular, only users in the two allowed groups will be let in (see
[OpenSSH Server: understanding Allow\* and Deny\* stuff][post] for some
details), and both are constrained to only use `internal-sftp`. I
decided to leave the `ForceCommand` directive inside both `Match`es,
should I change my mind later and allow other groups to get a shell
access.

I'm allowing username/password pairs to make it easier for the
data readers, which might not be comfortable with SSH keys. A lot of the
restrictions are probably never used due to the constraints on SFTP,
I'll try to study them more at time goes.

The `ChrootDirectory` allows restricting *where* the connecting users
can go. Here I'm anticipating some *readers* which will each be allowed
access to their own directory, read-only; on the other hand, one or more
*writers* will have a wider access to `/var/sftp`, so that they will be
able to *see* all directories.

I hope I didn't forget anything important... if I did, please raise your
hand!

Stay safe everyone!

[Perl]: https://www.perl.org/
[Raku]: https://raku.org/
[post]: {{ '/2021/10/24/sshd-deny-allow/' | prepend: site.baseurl }}
[OpenSSH]: https://www.openssh.com/
