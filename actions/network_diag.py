import argparse
import importlib
import json
import socket
import subprocess
import sys
import time
import urllib.request

# Dynamic check and installation of psutil
try:
    psutil = importlib.import_module("psutil")
except ImportError:
    print("[*] Installing missing dependency: psutil...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "psutil"])
    psutil = importlib.import_module("psutil")


class NetworkDiagnostics:
    def __init__(self):
        self.report = {"timestamp": time.strftime("%Y-%m-%d %H:%M:%S"), "checks": {}}

    def check_interfaces(self):
        """Fetch all local network adapters and IP assignments."""
        adapters = {}
        for iface, addrs in psutil.net_if_addrs().items():
            adapters[iface] = []
            for addr in addrs:
                if addr.family == socket.AF_INET:
                    adapters[iface].append({"type": "IPv4", "ip": addr.address, "mask": addr.netmask})
                elif hasattr(psutil, "AF_LINK") and addr.family == psutil.AF_LINK:
                    adapters[iface].append({"type": "MAC", "address": addr.address})
        self.report["checks"]["interfaces"] = adapters

    def check_primary_ip(self):
        """Find active default local IP address."""
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            s.connect(("8.8.8.8", 80))
            local_ip = s.getsockname()[0]
        except Exception:
            local_ip = "127.0.0.1"
        finally:
            s.close()
        self.report["checks"]["primary_local_ip"] = local_ip

    def check_dns_resolution(self, targets=["google.com", "cloudflare.com"]):
        """Test DNS resolution speed and accuracy."""
        dns_results = {}
        for target in targets:
            start = time.time()
            try:
                ip = socket.gethostbyname(target)
                latency_ms = round((time.time() - start) * 1000, 2)
                dns_results[target] = {"status": "SUCCESS", "ip": ip, "lookup_time_ms": latency_ms}
            except socket.gaierror:
                dns_results[target] = {"status": "FAILED", "ip": None, "lookup_time_ms": None}
        self.report["checks"]["dns"] = dns_results

    def check_port_connectivity(self, hosts=[("1.1.1.1", 53), ("8.8.8.8", 53), ("google.com", 443)]):
        """Test TCP socket reachability and latency."""
        connectivity = {}
        for host, port in hosts:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(3.0)
            start = time.time()
            try:
                s.connect((host, port))
                latency_ms = round((time.time() - start) * 1000, 2)
                connectivity[f"{host}:{port}"] = {"status": "OPEN", "latency_ms": latency_ms}
            except Exception as e:
                connectivity[f"{host}:{port}"] = {"status": "FAILED", "error": str(e)}
            finally:
                s.close()
        self.report["checks"]["port_connectivity"] = connectivity

    def check_public_ip(self):
        """Fetch WAN IP and check internet egress capability."""
        try:
            req = urllib.request.urlopen("https://api.ipify.org?format=json", timeout=3)
            public_ip = json.loads(req.read().decode())["ip"]
            self.report["checks"]["public_ip"] = {"status": "ONLINE", "ip": public_ip}
        except Exception as e:
            self.report["checks"]["public_ip"] = {"status": "OFFLINE/BLOCKED", "error": str(e)}

    def check_dns_connectivity(self, targets):
        """Test DNS resolution for a provided list of target addresses."""
        if isinstance(targets, str):
            targets = [targets]

        dns_results = {}
        for target in targets:
            start = time.time()
            try:
                ip = socket.gethostbyname(target)
                latency_ms = round((time.time() - start) * 1000, 2)
                dns_results[target] = {"status": "SUCCESS", "ip": ip, "lookup_time_ms": latency_ms}
            except socket.gaierror:
                dns_results[target] = {"status": "FAILED", "ip": None, "lookup_time_ms": None}

        self.report["checks"]["dns"] = dns_results
        return dns_results

    def run_all(self, default_targets=["google.com", "cloudflare.com"]):
        """Execute full diagnostic suite."""
        print("[+] Running Network Diagnostic Suite...")
        self.check_interfaces()
        self.check_primary_ip()
        self.check_dns_resolution()
        self.check_port_connectivity()
        self.check_public_ip()
        self.check_dns_connectivity(default_targets)
        return self.report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Network Diagnostic Tool")
    parser.add_argument(
        "--run-all",
        action="store_true",
        help="Execute full network diagnostic suite",
    )
    parser.add_argument(
        "--check-dns-connectivity",
        type=str,
        nargs="+",
        metavar="ADDRESS",
        help="Check DNS connectivity for custom address(es)",
    )

    args = parser.parse_args()
    diag = NetworkDiagnostics()

    if args.run_all:
        results = diag.run_all()
        print(json.dumps(results, indent=2))
    elif args.check_dns_connectivity:
        results = diag.check_dns_connectivity(args.check_dns_connectivity)
        print(json.dumps(results, indent=2))
    else:
        parser.print_help()
