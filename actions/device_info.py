import importlib
import subprocess
import sys

# Dynamic check and installation of psutil
try:
    psutil = importlib.import_module("psutil")
except ImportError:
    print("psutil not found. Installing now...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "psutil"])
    psutil = importlib.import_module("psutil")
    print("psutil installed successfully!\n")

# --- CPU Details ---
print("=== CPU Info ===")
print(f"Physical Cores: {psutil.cpu_count(logical=False)}")
print(f"Total Threads: {psutil.cpu_count(logical=True)}")
print(f"CPU Usage: {psutil.cpu_percent(interval=1)}%")

# --- RAM Memory ---
ram = psutil.virtual_memory()
print("\n=== RAM Info ===")
print(f"Total RAM: {ram.total / (1024**3):.2f} GB")
print(f"Available RAM: {ram.available / (1024**3):.2f} GB")
print(f"Used RAM: {ram.percent}%")

# --- Storage / Disk ---
disk = psutil.disk_usage('/')
print("\n=== Storage Info ===")
print(f"Total Space: {disk.total / (1024**3):.2f} GB")
print(f"Used Space: {disk.used / (1024**3):.2f} GB")
print(f"Free Space: {disk.free / (1024**3):.2f} GB")

# --- Battery ---
battery = psutil.sensors_battery()
if battery:
    print("\n=== Battery Info ===")
    print(f"Battery Left: {battery.percent}%")
    print(f"Power Plugged In: {battery.power_plugged}")
