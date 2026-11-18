import os
import sys

print("Python action running !")

print(f"Python version: {sys.version.split()[0]}")
print(f"Workspace: {os.environ.get('WORKSPACE', 'not defined')}")

print("Argument: ")

for argument in sys.argv[1:]:
	print(f"  {argument}")

