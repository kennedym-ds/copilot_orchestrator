import subprocess
import json
import sys
from pathlib import Path

# Configuration
PYTHON_EXE = sys.executable
SERVER_SCRIPT = str(Path(__file__).parent / "mcp" / "design_server.py")

def test_handshake():
    print(f"Launching server: {PYTHON_EXE} {SERVER_SCRIPT}")
    
    # Start the server process
    process = subprocess.Popen(
        [PYTHON_EXE, SERVER_SCRIPT],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    # JSON-RPC Initialize Request
    # Note: The MCP protocol expects a specific initialization flow.
    # We'll send a basic JSON-RPC request to see if we get a valid JSON-RPC response or error.
    # Even an error means the server is listening and parsing JSON.
    
    init_request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "test-client", "version": "1.0"}
        }
    }

    try:
        json_payload = json.dumps(init_request)
        print(f"Sending: {json_payload}")
        
        process.stdin.write(json_payload + "\n")
        process.stdin.flush()

        print("Waiting for response (timeout 5s)...")
        # Read line-by-line
        response_line = process.stdout.readline()
        
        print(f"Received raw: {response_line.strip()}")
        
        if not response_line:
            stderr_out = process.stderr.read()
            print(f"No response. Stderr: {stderr_out}")
            return False

        response_data = json.loads(response_line)
        print("Parsed JSON response successfully.")
        
        if "result" in response_data or "error" in response_data:
            print("✅ Server is speaking JSON-RPC.")
            return True
            
    except Exception as e:
        print(f"❌ Exception during handshake: {e}")
        return False
    finally:
        process.terminate()
        process.wait()

if __name__ == "__main__":
    success = test_handshake()
    sys.exit(0 if success else 1)
