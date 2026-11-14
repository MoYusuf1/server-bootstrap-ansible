# Setup: Ansible, the VM and a snapshot

About 45 minutes, most of it the Ubuntu install.

## 1. Install Ansible on your PC

Ansible runs only on your PC (the "control node"). Nothing is installed on the server first. Ansible uses SSH and the Python that Ubuntu already has.

Arch or CachyOS:

```bash
sudo pacman -S --needed ansible
```

Ubuntu or Debian:

```bash
sudo apt update && sudo apt install -y ansible
```

Windows: Ansible does not run on Windows itself. Install WSL2 with Ubuntu in PowerShell (`wsl --install -d Ubuntu-24.04`), open the Ubuntu terminal, and use the Ubuntu command above. Do all the steps below from that terminal.

Check it:

```bash
ansible --version
```

The full `ansible` package includes the two collections this repo uses. If you have only `ansible-core`, run `make deps`.

## 2. Make an SSH key (skip if you have one)

```bash
ls ~/.ssh/id_ed25519.pub || ssh-keygen -t ed25519
```

The `.pub` file is the public key. You can share it. Never share or commit the file without `.pub`.

## 3. Build the VM

On Linux, use virt-manager. It uses KVM, which is built into the kernel, and the VM gets an IP your PC can reach with no port forwarding. VirtualBox also works, but use a "Bridged" or "Host-only" adapter so your PC can reach the VM.

Install virt-manager on Arch or CachyOS, and let your user manage VMs:

```bash
sudo pacman -S --needed virt-manager libvirt dnsmasq qemu-desktop
```

```bash
sudo systemctl enable --now libvirtd
```

```bash
sudo usermod -aG libvirt $USER
```

Log out and in again so the group change works. Then start the default network:

```bash
sudo virsh net-autostart default && sudo virsh net-start default
```

Create the VM:

1. Download the Ubuntu 24.04 LTS Server ISO from ubuntu.com/download/server.
2. Open virt-manager. Click **Create a new virtual machine** and pick the ISO.
3. Give it 2 CPUs, 2 GB RAM and a 20 GB disk. Name it `bootstrap-vm`.
4. In the Ubuntu installer, accept the defaults. Make your user (example: `mo`) with a password you will remember.
5. On the **SSH Setup** screen, tick **Install OpenSSH server**. Do not import keys there.
6. Skip the extra snaps. Reboot when it asks.

Find the VM's IP. In the VM console, log in and run `ip -4 addr`, or from your PC:

```bash
sudo virsh domifaddr bootstrap-vm
```

## 4. Set up SSH access

Copy your public key to the VM user. It asks for the VM password one time.

```bash
ssh-copy-id mo@192.168.122.50
```

Check that the key works with no password prompt:

```bash
ssh -o PasswordAuthentication=no mo@192.168.122.50 'hostnamectl | grep "Operating System"'
```

It must print `Ubuntu 24.04`. Then check Ansible can reach it:

```bash
make inventory
```

```bash
ansible all -m ping
```

Expect `"ping": "pong"`.

## 5. Take a clean snapshot

A snapshot saves the VM's disk as it is now. You can go back to this fresh state any time and run the playbook again from zero.

Shut down the VM first, so the snapshot is clean:

```bash
sudo virsh shutdown bootstrap-vm
```

```bash
sudo virsh snapshot-create-as bootstrap-vm fresh-install "Fresh Ubuntu 24.04, SSH key added"
```

```bash
sudo virsh start bootstrap-vm
```

To reset the VM later:

```bash
sudo virsh snapshot-revert bootstrap-vm fresh-install --running
```

In VirtualBox, use **Machine > Take Snapshot**, and **Restore** to go back.

If you ever rebuild the VM from scratch, it gets a new SSH host key. Remove the old one from your PC with `ssh-keygen -R 192.168.122.50`.
