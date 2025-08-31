# SubMagic 🪄

![SubMagic Banner](https://img.shields.io/badge/SubMagic-Subdomain%20Enumeration-purple?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)
![Bash](https://img.shields.io/badge/Bash-4.0+-red?style=for-the-badge)

**SubMagic** is a comprehensive subdomain enumeration script that combines multiple industry-standard tools to provide maximum coverage and accuracy in subdomain discovery. Built for penetration testers, bug bounty hunters, and security researchers.

## 🎯 Features

- **Multi-Tool Integration**: Combines 6 powerful subdomain enumeration tools
- **Automated Installation**: Installs missing tools automatically
- **API Key Management**: Automatically configures API keys for enhanced results
- **Batch Processing**: Process multiple domains from a single file
- **Duplicate Removal**: Smart deduplication across all results
- **Progress Tracking**: Real-time progress monitoring
- **Robust Error Handling**: Continues execution even if some tools fail
- **Organized Output**: Clean, structured results with detailed statistics

## 🛠️ Tools Integrated

| Tool | Purpose | Flags Used |
|------|---------|------------|
| **Subfinder** | Multi-source passive enumeration | `-all` |
| **Amass** | Advanced DNS enumeration | `-passive` |
| **Assetfinder** | Fast subdomain discovery | `--subs-only` |
| **Findomain** | Certificate transparency logs | Default |
| **Github-subdomains** | GitHub code search | Auto-token |
| **Crt.sh** | Certificate transparency API | Via curl/jq |

## 📋 Prerequisites

- **Go** (golang) installed and in PATH
- **System package manager** (apt/yum/pacman) for curl/jq installation

## 🚀 Installation

### Quick Install
```bash
# Clone the repository
git clone https://github.com/yourusername/submagic.git
cd submagic

# Make executable
chmod +x submagic.sh

# Run (will auto-install missing dependencies)
./submagic.sh -l domains.txt
```

### Manual Tool Installation
If you prefer to install tools manually:

```bash
# Go-based tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/owasp-amass/amass/v4/...@master
go install github.com/tomnomnom/assetfinder@latest
go install github.com/gwen001/github-subdomains@latest

# System dependencies
sudo apt install curl jq  # Ubuntu/Debian
sudo yum install curl jq  # RHEL/CentOS
sudo pacman -S curl jq    # Arch Linux

# Findomain (binary download)
# Will be downloaded automatically by the script
```

## 💡 Usage

### Basic Usage
```bash
./submagic.sh -l domains.txt
```

### Options
```bash
Usage: ./submagic.sh -l <domains_file>

Options:
  -l    File with domain list (one per line)
  -h    Show help

Example:
  ./submagic.sh -l /tmp/domains.txt
```

### Input Format
Create a `domains.txt` file with one domain per line:
```
google.com
example.com
github.com
stackoverflow.com
```

## 🔧 API Configuration

SubMagic automatically configures API keys for enhanced results. The configuration file is created at `~/.config/subfinder/provider-config.yaml`.

### Supported APIs
- **Censys**: Certificate search
- **Chaos**: ProjectDiscovery database
- **Fofa**: Cybersecurity search engine
- **GitHub**: Code search (3 tokens for rate limiting)
- **LeakIX**: Leak and exposure search
- **Netlas**: Internet intelligence
- **SecurityTrails**: Historical DNS data
- **Shodan**: IoT/device search engine
- **VirusTotal**: Threat intelligence

### Custom API Keys
To use your own API keys, edit the configuration file:
```bash
nano ~/.config/subfinder/provider-config.yaml
```

## 📁 Output Structure

```
submagic_results_20241230_123456/
├── google.com.txt                   # Subdomains for google.com
├── example.com.txt                  # Subdomains for example.com
├── github.com.txt                   # Subdomains for github.com
└── all_subdomains_final.txt         # ALL unique subdomains combined
```

## 📊 Sample Output

```bash
[*] SubMagic - Mass Subdomain Enumeration Script

[*] Verifying dependencies...
[✓] All dependencies are installed

[*] Processing 3 domains...

[*] Progress: 1/3
[*] Processing domain: google.com
================================
[*] Running subfinder with -all for google.com...
[✓] Subfinder found 156 subdomains (using all sources)
[*] Running amass enum -passive for google.com...
[✓] Amass found 89 subdomains (passive mode)
[*] Running assetfinder --subs-only for google.com...
[✓] Assetfinder found 45 subdomains (subs only)
[*] Running findomain for google.com...
[✓] Findomain found 23 subdomains
[*] Running github-subdomains for google.com...
[✓] Github-subdomains found 12 subdomains
[*] Running crt.sh query for google.com...
[✓] Crt.sh found 67 subdomains
[✓] Total unique subdomains for google.com: 234

[*] Combining all results...
================================
[✓] Process completed successfully
[✓] Total unique subdomains found: 1,247
[✓] Results saved in: submagic_results_20241230_123456/all_subdomains_final.txt
================================
```

## 🔥 Advanced Features

### Automatic Tool Installation
On first run, SubMagic detects missing tools and offers automatic installation:
```bash
[!] Missing tools: subfinder amass findomain
[?] Do you want to automatically install missing tools? (y/n) y
[*] Installing missing tools...
[✓] All tools installed successfully
```

### GitHub Token Management
Automatically extracts and uses GitHub tokens from the Subfinder configuration:
- Supports multiple tokens for rate limiting
- Falls back gracefully if no tokens are available
- Uses the first available token automatically

### Robust Error Handling
- Continues execution even if individual tools fail
- Creates empty files for failed tools to prevent pipeline breaks
- Provides clear status messages for each tool
- Graceful degradation with partial results

## ⚡ Performance Tips

1. **Use API Keys**: Configure API keys for maximum results
2. **Multiple GitHub Tokens**: Add multiple GitHub tokens to avoid rate limiting
3. **Batch Processing**: Process multiple domains in one run for efficiency
4. **SSD Storage**: Use fast storage for better I/O performance during large scans

## 🐛 Troubleshooting

### Common Issues

**Tool not found errors:**
```bash
# Ensure Go is in your PATH
export PATH=$PATH:$(go env GOPATH)/bin
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
source ~/.bashrc
```

**Permission denied:**
```bash
chmod +x submagic.sh
```

**API rate limiting:**
- Add more API keys to the configuration file
- Use multiple GitHub tokens
- Add delays between domains if needed

**Empty results:**
- Check internet connectivity
- Verify API keys are valid
- Ensure domains are publicly accessible

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup
```bash
git clone https://github.com/yourusername/submagic.git
cd submagic
./submagic.sh -h
```

### Adding New Tools
To add a new enumeration tool:
1. Create a new function following the pattern `run_toolname()`
2. Add tool verification to `check_dependencies()`
3. Add installation logic to `install_missing_tools()`
4. Call the function in `process_domain()`

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This tool is for educational and authorized testing purposes only. Users are responsible for complying with applicable laws and regulations. The developers assume no responsibility for misuse of this tool.

## 🙏 Acknowledgments

- [ProjectDiscovery](https://github.com/projectdiscovery) for Subfinder
- [OWASP](https://github.com/OWASP/Amass) for Amass
- [TomNomNom](https://github.com/tomnomnom) for Assetfinder
- [Findomain](https://github.com/Findomain/Findomain) team
- [Gwen001](https://github.com/gwen001) for Github-subdomains
- Certificate Transparency logs community

## 📞 Support

- Create an [Issue](https://github.com/yourusername/submagic/issues) for bug reports
- [Discussions](https://github.com/yourusername/submagic/discussions) for questions and ideas
- Follow [@soyel_mago](https://twitter.com/soel_mago) for updates

---

**Made with ❤️ for the cybersecurity community**
