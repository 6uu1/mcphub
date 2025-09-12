#!/usr/bin/env python3
"""
MCPHub - Model Context Protocol Server Hub
Entry point for Hugging Face Spaces deployment

This script serves as the main entry point for the MCPHub application
when deployed on Hugging Face Spaces. It starts the Node.js server
with the appropriate configuration for the HF Spaces environment.
"""

import os
import subprocess
import sys
import signal
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def check_environment():
    """Check if the environment is properly configured for HF Spaces"""
    logger.info("🔍 Checking Hugging Face Spaces environment...")
    
    # Set HF_SPACE environment variable if not set
    if not os.getenv('HF_SPACE'):
        os.environ['HF_SPACE'] = '1'
        logger.info("✅ Set HF_SPACE environment variable")
    
    # Ensure PORT is set to 7860 (HF Spaces requirement)
    if not os.getenv('PORT'):
        os.environ['PORT'] = '7860'
        logger.info("✅ Set PORT to 7860 for HF Spaces")
    
    # Set HOST to bind to all interfaces
    if not os.getenv('HOST'):
        os.environ['HOST'] = '0.0.0.0'
        logger.info("✅ Set HOST to 0.0.0.0")
    
    # Set production environment
    if not os.getenv('NODE_ENV'):
        os.environ['NODE_ENV'] = 'production'
        logger.info("✅ Set NODE_ENV to production")
    
    # Check if the built application exists
    dist_path = Path('dist')
    if not dist_path.exists():
        logger.error("❌ Application not built. dist/ directory not found.")
        return False
        
    index_path = dist_path / 'index.js'
    if not index_path.exists():
        logger.error("❌ Main application file not found: dist/index.js")
        return False
    
    logger.info("✅ Environment check completed successfully")
    return True

def start_server():
    """Start the MCPHub Node.js server"""
    try:
        logger.info("🚀 Starting MCPHub server...")
        
        # Change to the application directory
        app_dir = Path.cwd()
        logger.info(f"📁 Working directory: {app_dir}")
        
        # Start the Node.js application
        cmd = ['node', 'dist/index.js']
        logger.info(f"🔧 Executing command: {' '.join(cmd)}")
        
        # Start the process
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines=True,
            bufsize=1
        )
        
        logger.info(f"✅ Server process started with PID: {process.pid}")
        
        # Handle graceful shutdown
        def signal_handler(signum, frame):
            logger.info(f"🛑 Received signal {signum}, shutting down gracefully...")
            process.terminate()
            try:
                process.wait(timeout=10)
                logger.info("✅ Server shut down gracefully")
            except subprocess.TimeoutExpired:
                logger.warning("⚠️  Server did not shut down gracefully, forcing termination")
                process.kill()
            sys.exit(0)
        
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGINT, signal_handler)
        
        # Stream output in real-time
        while True:
            output = process.stdout.readline()
            if output == '' and process.poll() is not None:
                break
            if output:
                print(output.strip())
        
        # Get the return code
        rc = process.poll()
        if rc != 0:
            logger.error(f"❌ Server exited with code {rc}")
            sys.exit(rc)
        else:
            logger.info("✅ Server exited normally")
            
    except KeyboardInterrupt:
        logger.info("🛑 Received keyboard interrupt, shutting down...")
        if 'process' in locals():
            process.terminate()
        sys.exit(0)
    except Exception as e:
        logger.error(f"❌ Failed to start server: {e}")
        sys.exit(1)

def main():
    """Main entry point"""
    logger.info("🌟 MCPHub - Model Context Protocol Server Hub")
    logger.info("🤗 Starting in Hugging Face Spaces mode...")
    
    # Check environment
    if not check_environment():
        logger.error("❌ Environment check failed")
        sys.exit(1)
    
    # Print startup information
    logger.info("📊 Environment Information:")
    logger.info(f"   - Python Version: {sys.version}")
    logger.info(f"   - Working Directory: {Path.cwd()}")
    logger.info(f"   - PORT: {os.getenv('PORT', 'not set')}")
    logger.info(f"   - HOST: {os.getenv('HOST', 'not set')}")
    logger.info(f"   - NODE_ENV: {os.getenv('NODE_ENV', 'not set')}")
    
    # Start the server
    start_server()

if __name__ == "__main__":
    main()