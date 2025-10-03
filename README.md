# Scanning Common Services Script

> **Disclaimer**  
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
9. [Output / Report Format](#output--report-format)  
10. [Limitations / Caveats](#limitations--caveats)  
11. [Contribution & Roadmap](#contribution--roadmap)  
12. [License](#license)  

---

## Overview

The **Scanning Common Services Script** is a shell script designed to:

- Scan one or more target IP addresses or hostnames for open ports  
- Identify and probe commonly used services (e.g. FTP, SSH, HTTP, SMB)  
- Provide a summary of findings  

It’s a lightweight, minimal-dependency tool for quick reconnaissance or sanity checks in security assessments.

---

## Features

- Port scanning
- Service identification for key ports  
- Simple, human-readable output  
- Batch mode

---

## Requirements

- Unix-like environment (Linux, macOS, BSD)  
- Shell (bash, sh)  
- Common networking tools available (e.g. `nc`, `nmap`, `curl`)  
- Internet / network reachability to the target  

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/LucaParsani/Scanning-Common-Services-Script.git
cd Scanning-Common-Services-Script

