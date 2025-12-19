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
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 { color: #0078D4; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to RHEL 9 on Azure!</h1>
        <p>This web server was automatically created and configured using Terraform!</p>
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
