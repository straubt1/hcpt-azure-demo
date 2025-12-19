#!/bin/bash
# Install Apache web server
dnf install -y httpd

# Create a simple HTML page
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>RHEL 9 VM on Azure</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 1200px;
            margin: 20px auto;
        }
        h1 { color: #0078D4; }
        .diagram {
            margin: 30px 0;
            text-align: center;
        }
        .diagram img {
            max-width: 100%;
            height: auto;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            padding: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to RHEL 9 on Azure!</h1>
        <p>This web server was automatically created and configured using Terraform!</p>
        <div class="diagram">
            <h2>Terraform Cloud Workflow</h2>
            <img src="https://www.hashicorp.com/_next/image?url=https%3A%2F%2Fwww.datocms-assets.com%2F2885%2F1696969711-packer-self-service.png&w=3840&q=75" alt="Terraform Cloud Workflow Diagram" />
        </div>
    </div>
</body>
</html>
HTML

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Open firewall for HTTP
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
