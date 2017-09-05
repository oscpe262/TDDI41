# Ansible role 'DNS'

An Ansible role for setting up resolv.conf for the DNS lab (TDDI41).

## Requirements
The role requires the bind server hostname to be `server`.

## Role Variables
| Variable                       | Default                          | Comments (type)  |
| :---                           | :---                             | :---             |
| srv_ip | 154 | Currently only supporting 130.236.178.0, if assigned 179, adjust accordingly in the template |
## Dependencies

## Example Playbook
```Yaml
- hosts: foo
  roles:
    - role: DNS
```

## Testing

## License

BSD

## Contributors

Issues, feature requests, ideas, suggestions, etc. are appreciated and can be posted in the Issues section. Pull requests are also very welcome. Please create a topic branch for your proposed changes, it's the easiest way to merge back into the project.

- [Oscar Petersson](https://github.com/oscpe262/) (Maintainer)
