# Lab notes

Write only what you saw. Write "not measured" if you did not capture a value. Times are from the terminal output.

## Run 1 · 2026-11-13

- Ansible version (`ansible --version`): ansible 14.6.0, ansible-core 2.21.6
- VM: Ubuntu 24.04.5, 2 vCPU, 2 GB RAM, 12 GB disk (KVM)
- Dry run on the fresh VM: ok=25 changed=15 failed=0 skipped=1 ignored=5
- First real run: ok=26 changed=17 failed=0
- First real run time: 51 s
- Second run: ok=24 changed=0 failed=0
- Second run time: 8.6 s
- `make verify`: pass (8 ok, 0 failed)
- Password login attempt from the host, exact error: `deploy@...: Permission denied (publickey).` Root: same.
- Docker vs UFW drill: yes, HTTP 200 while UFW allowed only 22/tcp. With `-p 127.0.0.1:8080:80`: `Operation timed out after 5001 milliseconds` (000).
- fail2ban drill: all 8 attempts said Permission denied; the ban took effect right after the loop (console: Total failed 8, Currently banned 1).
- fail2ban drill: what the ban looked like from the host: `Connection timed out during banner exchange`
- Surprises: the first dry run failed (`No package matching 'fail2ban' is available`) because check mode skipped the apt list refresh. The fail2ban restart handler also failed in check mode. Both fixed.
