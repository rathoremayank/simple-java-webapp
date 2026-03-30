#!/bin/bash

# Jenkins Credentials Setup Script
# This script helps configure required credentials in Jenkins

set -e

echo "=========================================="
echo "Jenkins Credentials Setup Helper"
echo "=========================================="
echo ""

# Check if Jenkins CLI is available
if ! command -v jenkins-cli &> /dev/null; then
    echo "⚠️  Jenkins CLI not found. Please install jenkins-cli:"
    echo "   sudo apt-get install jenkins-cli"
    echo ""
    echo "Or download from: https://jenkins-server/jnlpJars/jenkins-cli.jar"
    exit 1
fi

JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"
JENKINS_USER="${JENKINS_USER:-admin}"

echo "Jenkins URL: $JENKINS_URL"
echo "Jenkins User: $JENKINS_USER"
echo ""

# Function to create credential
create_credential() {
    local cred_id=$1
    local cred_type=$2
    local cred_data=$3
    
    echo "Creating credential: $cred_id ($cred_type)"
    
    case $cred_type in
        "secret-text")
            echo "$cred_data" | jenkins-cli -s $JENKINS_URL -auth $JENKINS_USER create-credentials-by-xml system::system::jenkins credential-impl::SecretTextCredentialsImpl << EOL
<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>$cred_id</id>
  <description>$cred_id</description>
  <secret>${cred_data}</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOL
            ;;
        "username-password")
            local username=$(echo $cred_data | cut -d: -f1)
            local password=$(echo $cred_data | cut -d: -f2)
            
            echo "$cred_data" | jenkins-cli -s $JENKINS_URL -auth $JENKINS_USER create-credentials-by-xml system::system::jenkins credential-impl::UsernamePasswordCredentialsImpl << EOL
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>$cred_id</id>
  <description>$cred_id</description>
  <username>$username</username>
  <password>$password</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOL
            ;;
    esac
    
    echo "✓ Credential created: $cred_id"
}

# Manual setup instructions
cat << 'EOF'

========== MANUAL CREDENTIAL SETUP ==========

Follow these steps in Jenkins UI:

1. DOCKER HUB CREDENTIALS
   - Go to: Jenkins → Manage Credentials → System → Global credentials
   - Click: "Add Credentials"
   - Kind: Username with password
   - Username: <your-dockerhub-username>
   - Password: <your-dockerhub-access-token>
   - ID: docker-hub-credentials
   - Description: Docker Hub Credentials
   - Click: Create

2. SONARCLOUD TOKEN
   - Go to: Jenkins → Manage Credentials → System → Global credentials
   - Click: "Add Credentials"
   - Kind: Secret text
   - Secret: <your-sonarcloud-token>
   - ID: sonarcloud-token
   - Description: SonarCloud Authentication Token
   - Click: Create

3. SONARCLOUD HOST URL
   - Go to: Jenkins → Manage Credentials → System → Global credentials
   - Click: "Add Credentials"
   - Kind: Secret text
   - Secret: https://sonarcloud.io
   - ID: sonarcloud-host-url
   - Description: SonarCloud Host URL
   - Click: Create

4. SCM CREDENTIALS (if using private repository)
   - Go to: Jenkins → Manage Credentials → System → Global credentials
   - Click: "Add Credentials"
   - Kind: SSH Key (for Git SSH) or Username with password (for HTTPS)
   - For SSH:
     * Private Key: <paste your SSH private key>
     * Passphrase: <leave empty if no passphrase>
   - For HTTPS:
     * Username: <github-username>
     * Password: <github-personal-access-token>
   - ID: scm-credentials
   - Description: SCM Repository Credentials
   - Click: Create

========== HOW TO GET THE TOKENS ==========

Docker Hub Access Token:
  1. Go to: https://hub.docker.com/settings/security
  2. Click: "New Access Token"
  3. Give it name "Jenkins"
  4. Copy the token

SonarCloud Token:
  1. Go to: https://sonarcloud.io/account/security
  2. Click: "Generate Tokens"
  3. Give it name "Jenkins"
  4. Copy the token

GitHub Personal Access Token:
  1. Go to: https://github.com/settings/tokens
  2. Click: "Generate new token"
  3. Select scopes: repo, read:user
  4. Copy the token

========== VERIFICATION ==========

After setting up credentials, verify in Jenkins:
  1. Go to: Jenkins → Manage Credentials → System → Global credentials
  2. You should see:
     - docker-hub-credentials
     - sonarcloud-token
     - sonarcloud-host-url
     - scm-credentials (if applicable)

EOF

echo ""
echo "✓ Setup instructions displayed"
echo ""
