# Ansible role 'NFS'

An Ansible role for setting up NFS lab in TDDI41

## Requirements

## Role Variables
| Variable                       | Default                          | Comments (type)  |
| :---                           | :---                             | :---             |
| nfs_exports | [] | list of exports |
| is_server | | Set to True for server |
## Dependencies

## Example Playbook
```Yaml
- hosts: foo
  roles:
    - role: NFS
      is_server: True
      nfs_exports:
        - "/srv/nfs/ *(fsid=0,rw,sync)" 
```

## Testing

## License

BSD

## Contributors

Issues, feature requests, ideas, suggestions, etc. are appreciated and can be posted in the Issues section. Pull requests are also very welcome. Please create a topic branch for your proposed changes, it's the easiest way to merge back into the project.

- [Oscar Petersson](https://github.com/oscpe262/) (Maintainer)
