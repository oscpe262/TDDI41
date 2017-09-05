# Ansible role 'NET'

As the ansible part of the course is written after I finished the course, I can't be arsed to write a bootstrap role or mess with Quagga. I suggest that you either a) write it yourself, b) use the NET script found elsewhere in this repo, c) use the course's UML script's extended functionality to bootstrap stuff as you want it, or d) just do this lab manually. (a) or (d) is recommended for beginners, in particular (a).

What you need to do is (for all clients, unless stated otherwise):
- Edit `/etc/hostname`
- Edit `/etc/resolv.conf`
- Edit `/etc/apt/sources.conf`
- Receive keys with `apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553 7638D0442B90D010 6FB2A1C265FFB764`
- Edit `/etc/network/interfaces`
- Edit `/etc/hosts`
- Edit `/etc/sysctl.conf`
- Install `quagga` (or some other routing software) on the gw and configure it.
- Install `ssh` and preferrably (mandatory if you are to use any scripts or ansible stuff) ssh keys and python2 support packages.

This will take a while if you are not used to unix or linux administrations, but shouldn't be very hard.

Once done, this specific role can be used as-is for NET-testing.

## Testing

## License

BSD

## Contributors

Issues, feature requests, ideas, suggestions, etc. are appreciated and can be posted in the Issues section. Pull requests are also very welcome. Please create a topic branch for your proposed changes, it's the easiest way to merge back into the project.

- [Oscar Petersson](https://github.com/oscpe262/) (Maintainer)
