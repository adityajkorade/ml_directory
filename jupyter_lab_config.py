# jupyter_lab_config.py

c = get_config()

# Set SSL certificate and key file paths
c.NotebookApp.certfile = u'/path/to/your/certificate.crt'
c.NotebookApp.keyfile = u'/path/to/your/private.key'

# Set other configurations
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.open_browser = False
c.NotebookApp.allow_root = True

# Enable the resource usage extension to monitor CPU and memory
c.ResourceUseDisplay.track_cpu_percent = True
c.ResourceUseDisplay.mem_limit = None
c.ResourceUseDisplay.cpu_limit = None
