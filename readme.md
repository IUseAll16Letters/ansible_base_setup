# Ansible script for first vds setup (currently init for x-ui server)
It is highly recommended to use ingress for launching this script from and use py.venv for starting ansible.

### Roles call order
init-variables -> admin (dependecies: sudo -> vds-init) -> sshd -> _x-ui_ (not implemented yet)

### Required files / variables
1. Root password must be provided. Example:
   1. Create a file with secrets for vps ```touch inventory/host_vars/foo_bar.yml```
   2. Add ansible_ssh_pass. ```ansible-vault encrypt_string --stdin-name 'ansible_ssh_pass'```
   3. Output: ```ansible_ssh_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256```
   4. Save values to file, encrypt file ```ansible-vault encrypt ./inventory/host_vars/foo_bar.yml```

2. admin role must have ```users: [list[dict[str, Any]]]``` variable; with: name, password, comment keys.
   1. to save password properly: ```pip install passlib```
   2. ```python -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"```

3. sshd role can set custom port for sshd on target node;
4. vds-init role has additional packages that are to be installed on target node;

## Usage:  
    ./play.sh [OPTIONS] <target_host_group>\\n
### Options:
    -n, --dry-run   No run, only init and create playbook.yml
    -h, --help      Print help
    target_host     Name (or group) of a target host(s)


## Installation
For ubuntu/debian:
1. install uv and Python 3.12
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh && uv python install 3.12
```

2. Clone project
```bash
git clone https://github.com/IUseAll16Letters/ansible_base_setup.git && cd ansible_base_setup
```

3. Venv + install dependencies
```bash
uv venv venv && source ./venv/bin/activate && uv pip install -r ./requirements.txt
```

4. Run shell script (read usage)
```bash
./play.sh 
```

## How to keep sudo passwords for hosts:
suggest your hostname is foo_bar

```bash
mkdir -p ./inventory/host_vars && ansible-vault create inventory/host_vars/foo_bar.yml
```
enter password, *.sh scrip will ask you for that password


## Working with roles
In order to have flexibility with roles and have access to roles variable 
create a file with your \<username\> inside group_vars, then put all your roles inside

```bash
mkdir -p ./inventory/group_vars && vi $_/username 
```
