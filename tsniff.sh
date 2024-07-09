#!/bin/bash

# Function to display usage instructions
display_usage() {
    echo "TSNIFF (by Veilwr4ith): a tcpdump and tshark Powered Packet Sniffer."
    echo "Usage: $0 [-i interface] [-d duration] [-p port] [-f filter] [-a <capture_file>] [-m] [-H] [-c] [-s] [-P protocol] [-M] [-S] [-o output_file] [-F protocol] [-h]"
    echo "Options:"
    echo "  -i interface   : Specify network interface (default: eth0)"
    echo "  -d duration    : Duration in seconds to capture traffic (default: 10)"
    echo "  -p port        : Filter by destination port"
    echo "  -f filter      : Additional tcpdump filter (e.g., 'host 192.168.1.1')"
    echo "  -a <capture_file> : Analyze captured traffic from specified pcap file"
    echo "  -m             : Monitor and display real-time traffic"
    echo "  -H             : Perform HTTP header analysis"
    echo "  -c             : Capture network traffic"
    echo "  -s             : Save captures with timestamps"
    echo "  -P protocol    : Analyze traffic for a specific protocol (e.g., tcp, udp, dhcp)"
    echo "  -M             : Extract metadata from pcap file"
    echo "  -S             : Perform statistical analysis on captured data"
    echo "  -o output_file : Save output to specified file"
    echo "  -F protocol    : Follow streams (TCP, UDP, DHCP, etc.)"
    echo "  -h             : Display this help message"
    exit 1
}

# Initialize default values for options
interface="eth0"
duration=10
port=""
filter=""
analyze=false
monitor=false
http_analysis=false
capture=false
save_with_timestamp=false
protocol=""
capture_file=""
extract_metadata=false
perform_stats=false
output_file=""
follow_streams=""

# Parse command line options
while getopts ":i:d:p:f:a:mHcsP:MSo:F:h" opt; do
    case $opt in
        i) interface="$OPTARG";;
        d) duration="$OPTARG";;
        p) port="$OPTARG";;
        f) filter="$OPTARG";;
        a) analyze=true; capture_file="$OPTARG";;
        m) monitor=true;;
        H) http_analysis=true;;
        c) capture=true;;
        s) save_with_timestamp=true;;
        P) protocol="$OPTARG";;
        M) extract_metadata=true;;
        S) perform_stats=true;;
        o) output_file="$OPTARG";;
        F) follow_streams="$OPTARG";;
        h) display_usage;;
        \?) echo "[-] Invalid option: -$OPTARG" >&2; display_usage;;
        :) echo "[-] Option -$OPTARG requires an argument." >&2; display_usage;;
    esac
done

# Function to perform real-time monitoring
real_time_monitor() {
    echo "[*] Real-time monitoring..."

    # Check if a filter is specified
    if [[ ! -z "$filter" ]]; then
        echo "[*] Monitoring traffic for host: $filter"
        sudo tcpdump -i "$interface" -n -l -q host "$filter" 2>/dev/null | while IFS= read -r line; do
            echo "$line"
        done
    else
        echo "[*] Monitoring all traffic..."
        sudo tcpdump -i "$interface" -n -l -q 2>/dev/null | while IFS= read -r line; do
            echo "$line"
        done
    fi
}

# Function to perform HTTP header analysis
http_header_analysis() {
    echo "[*] Performing HTTP header analysis on interface $interface..."
    sudo tcpdump -i "$interface" -A -s0 -l -n tcp port 80 2>/dev/null | grep -iE '^(GET|POST|HEAD)|^Host:|^Referer:|^User-Agent:'
}

# Function to follow streams
follow_streams_func() {
    if [[ -n "$capture_file" ]]; then
        echo "[*] Following $follow_streams streams in file: $capture_file..."
        if [[ -f "$capture_file" ]]; then
            case $follow_streams in
                tcp)
                    sudo tshark -r "$capture_file" -qz conv,tcp
                    echo -n "[*] Stream Number to follow: "
                    read command_to_execute
                    sudo tshark -r "$capture_file" -Y "tcp.stream eq $command_to_execute" -x
                    ;;
                udp)
                    sudo tshark -r "$capture_file" -qz conv,udp
                    echo -n "[*] Stream Number to follow: "
                    read command_to_execute
                    sudo tshark -r "$capture_file" -Y "udp.stream eq $command_to_execute" -x
                    ;;
                wlan)
                    sudo tshark -r "$capture_file" -qz conv,wlan
                    echo "[-] No Streaming available for wlan."
                    ;;
                eth)
                    sudo tshark -r "$capture_file" -qz conv,eth
                    echo "[-] No Streaming available for eth."
                    ;;
                *)
                    echo "[-] Unsupported protocol '$follow_streams'. Supported protocols: tcp, udp, eth, wlan"
                    ;;
            esac
        else
            echo "[-] Error: Provided capture file '$capture_file' not found."
        fi
    else
        echo "[-] Error: Please provide a capture file with option -a."
    fi
}

# Function to capture network traffic
capture_traffic() {
    echo "[*] Capturing network traffic on interface $interface..."
    if $keep_capture; then
        echo "[*] Capturing indefinitely. Press Ctrl+C to stop."
        if $save_with_timestamp; then
            sudo tcpdump -i "$interface" -w "capture_$(date +%Y%m%d_%H%M%S).pcap" -G 3600 -W 1 &> /dev/null &
        else
            sudo tcpdump -i "$interface" -w capture.pcap -G 3600 -W 1 &> /dev/null &
        fi
        wait $!
    else
        echo "[*] Capturing for $duration seconds..."
        if $save_with_timestamp; then
            filename="capture_$(date +%Y%m%d_%H%M%S).pcap"
            sudo tcpdump -i "$interface" -w "$filename" -G "$duration" -W 1 &> /dev/null &
        else
            sudo tcpdump -i "$interface" -w capture.pcap -G "$duration" -W 1 &> /dev/null &
        fi
        sleep "$duration"
    fi
}


# Function to analyze captured traffic
analyze_traffic() {
    if [[ -n "$capture_file" ]]; then
        echo "[*] Analyzing captured traffic from file: $capture_file..."
        if [[ -f "$capture_file" ]]; then
            # Display total packets captured
            packet_count=$(sudo tcpdump -r "$capture_file" | wc -l)
            echo "[+] Total packets captured: $packet_count"

            # Display summary of captured packets
            echo "[+] Packet summary:"
            sudo tcpdump -r "$capture_file" | head -n 10  # Display first 10 packets as an example

            # Extract and display unique IP addresses
            echo "[*] Extracting unique IP addresses..."
            sudo tcpdump -r "$capture_file" | awk '{print $3}' | sort -u  # Display unique IP addresses

            # Additional analysis based on options (e.g., filter by port)
            if [[ ! -z "$port" ]]; then
                echo "[*] Filtering traffic by destination port $port..."
                sudo tcpdump -r "$capture_file" "port $port"
            fi

            # Additional filter if specified
            if [[ ! -z "$filter" ]]; then
                echo "[*] Applying custom filter: $filter"
                sudo tcpdump -r "$capture_file" "$filter"
            fi

            # Protocol-specific analysis if specified
            if [[ ! -z "$protocol" ]]; then
                echo "[*] Analyzing traffic for protocol: $protocol"
                sudo tshark -r "$capture_file" -Y "$protocol"
            fi

            # Extract metadata if requested
            if $extract_metadata; then
                echo "[*] Extracting metadata from pcap file..."
                sudo tshark -r "$capture_file" -T fields -e frame.number -e frame.time -e ip.src -e ip.dst -e frame.len -e ip.proto -e _ws.col.Protocol | head -n 20
            fi

            # Perform statistical analysis if requested
            if $perform_stats; then
                echo "[*] Performing statistical analysis on captured data..."
                sudo tshark -r "$capture_file" -q -z io,stat,1
            fi

            # Save output to file if specified
            if [[ ! -z "$output_file" ]]; then
                echo "[*] Saving output to file: $output_file"
                sudo tshark -r "$capture_file" > "$output_file"
            fi

        else
            echo "[-] Error: Provided capture file '$capture_file' not found."
        fi
    else
        echo "[-] Error: Please provide a capture file with option -a."
    fi
}

# Perform capture if requested
if $capture; then
    capture_traffic
fi

# Analyze captured traffic if requested
if $analyze; then
    analyze_traffic
fi

# Follow streams if requested
if [[ ! -z "$follow_streams" ]]; then
    follow_streams_func
fi

# Perform real-time monitoring and display to terminal if requested
if $monitor; then
    real_time_monitor
fi

# Perform HTTP header analysis if requested
if $http_analysis; then
    http_header_analysis
fi

echo "[+] Script execution complete."

