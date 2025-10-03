# Scanning Common Services Script

> **Disclaimer:**
> This script is intended **solely for legal and ethical use**. Unauthorized scanning, probing, or exploitation of systems you do not own or have explicit permission to test is strictly prohibited. Use at your own risk.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Usage](#usage)
6. [Examples](#examples)
7. [How It Works / Internals](#how-it-works--internals)
8. [Supported Services / Ports](#supported-services--ports)
9. [Limitations / Caveats](#limitations--caveats)

---

## Overview

The **Scanning Common Services Script** is a shell script designed to:

* Scan one or more target IP addresses or hostnames for open ports
* Identify and probe commonly used services (e.g. FTP, SSH, HTTP, SMB)
* Provide a summary of findings

It’s a lightweight, minimal-dependency tool for quick reconnaissance or sanity checks in security assessments.

---

## Features

* Port scanning
* Service identification for key ports
* Simple, human-readable output to CLI and to file
* Batch mode

---

## Requirements

* Unix-like environment (Linux, macOS, BSD)
* Shell (bash, sh)
* Common networking tools available (`nmap`, `netexec`, `sslscan`, `ssh-audit`)
* Internet / network reachability to the target

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/LucaParsani/Scanning-Common-Services-Script.git
cd Scanning-Common-Services-Script
```

2. Ensure the script is executable:

```bash
chmod +x easyscan.sh
```

3. (Optional) Move it to a directory in your `$PATH`:

```bash
mv easyscan.sh /usr/local/bin/easyscan
```

---

## Usage

```bash
./easyscan.sh targets.txt
```

* `targets.txt` is a text file where each line is an IP address or hostname.
* The script will iterate through each target, perform scans and service probes, then emit a summary for each.

---

## Examples

Suppose `targets.txt` has:

```
192.168.1.10
example.com
```

Then:

```bash
./easyscan.sh targets.txt
```

Might output something like:

```
Target: 192.168.1.10
Open ports:
  22 (SSH) — banner: OpenSSH_8.2
  80 (HTTP) — HTTP title: “Welcome to Apache”
  445 (SMB) — SMB share count: 3

Target: example.com
Open ports:
  80 (HTTP) — HTTP title: “Example Domain"
  443 (HTTPS) — TLS version: TLSv1.2
```

---

## How It Works / Internals

Broadly, the script:

1. Reads targets line by line
2. For each target, performs a port scan (via nmap)
3. For each open port matching known services, sends probing requests (e.g. `nmap -sV`, `smbclient`, etc.)
4. Parses responses
5. Prints a summary per target both to CLI and to the file `log.txt`.

---

## Supported Services / Ports

Currently, the script supports probing these ports / services:

* 21 — FTP
* 22 — SSH
* 23 — Telnet
* 80 — HTTP
* 443 — HTTPS
* 445 — SMB

---

## Limitations / Caveats

* Probes might be blocked by firewalls or network filters
* Not stealthy — it’s not designed for evasion
* Limited set of services by default
* Timing and concurrency are basic; large target sets may take long
