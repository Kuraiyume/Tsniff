# TSNIFF - TCPDump and TShark Powered Packet Sniffer

**TSNIFF** is a versatile packet sniffer utilizing `tcpdump` and `tshark` for capturing and analyzing network traffic. This tool allows for real-time monitoring, traffic capture, and detailed analysis of captured packets.

## Usage

```bash
chmod +x tsniff.sh
```

```bash
./tsniff.sh [options]
```

## Options

- **`-i interface`**: Specify network interface (default: `eth0`)
- **`-d duration`**: Duration in seconds to capture traffic (default: `10`)
- **`-p port`**: Filter by destination port
- **`-f filter`**: Additional tcpdump filter (e.g., `host 192.168.1.1`)
- **`-a <capture_file>`**: Analyze captured traffic from specified pcap file
- **`-m`**: Monitor and display real-time traffic
- **`-H`**: Perform HTTP header analysis
- **`-c`**: Capture network traffic
- **`-s`**: Save captures with timestamps
- **`-P protocol`**: Analyze traffic for a specific protocol (e.g., `tcp`, `udp`, `dhcp`)
- **`-M`**: Extract metadata from pcap file
- **`-S`**: Perform statistical analysis on captured data
- **`-o output_file`**: Save output to specified file
- **`-F protocol`**: Follow streams (TCP, UDP, DHCP, etc.)
- **`-h`**: Display help message

## Features

- **Capture Network Traffic**: Capture traffic on a specified network interface for a given duration.
- **Real-Time Monitoring**: Monitor and display traffic in real-time.
- **HTTP Header Analysis**: Analyze HTTP headers in real-time.
- **Save Captures**: Save captured traffic to a file with optional timestamping.
- **Protocol Analysis**: Analyze traffic for specific protocols.
- **Metadata Extraction**: Extract metadata from pcap files.
- **Statistical Analysis**: Perform statistical analysis on captured data.
- **Follow Streams**: Follow TCP, UDP, or other streams in pcap files.
- **Custom Filtering**: Apply custom tcpdump filters.

## Examples

### Capture Traffic for 60 Seconds on `eth0`

```bash
./tsniff.sh -i eth0 -d 60 -c
```

### Monitor Real-Time Traffic on `eth0`

```bash
./tsniff.sh -i eth0 -m
```

### Analyze Captured Traffic from a File

```bash
./tsniff.sh -a capture.pcap
```

### Perform HTTP Header Analysis

```bash
./tsniff.sh -i eth0 -H
```

### Save Capture with Timestamps

```bash
./tsniff.sh -i eth0 -d 60 -c -s
```

### Follow TCP Streams in a Capture File

```bash
./tsniff.sh -a capture.pcap -F tcp
```

### Display Help

```bash
./tsniff.sh -h
```

## Requirements

- `tcpdump`

```bash
sudo apt install tcpdump
```
- `tshark`

```bash
sudo apt install tshark
```

## License

- MIT License

## Author

- Kuraiyume

## NOTE

- Ensure these tool are installed and have the necessary permissions to capture and analyze network traffic.
