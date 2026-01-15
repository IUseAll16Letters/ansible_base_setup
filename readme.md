# Ansible script for first vds setup (currently init for x-ui server)
It is highly recommended to use ingress for launching this script from and use py.venv for starting ansible.


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
