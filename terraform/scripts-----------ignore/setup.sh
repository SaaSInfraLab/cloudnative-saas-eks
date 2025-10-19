#!/bin/bash

# CloudNative SaaS EKS Platform - Setup Script
# Part of SaaSInfraLab - https://github.com/SaaSInfraLab

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        missing_tools+=("aws-cli")
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("terraform")
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "Please install the following:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                aws-cli)
                    echo "  AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
                    ;;
                terraform)
                    echo "  Terraform: https://developer.hashicorp.com/terraform/downloads"
                    ;;
                kubectl)
                    echo "  kubectl: https://kubernetes.io/docs/tasks/tools/"
                    ;;
            esac
        done
        exit 1
    fi
    
    print_success "All required tools are installed"
}

# Check AWS credentials
check_aws_credentials() {
    print_info "Checking AWS credentials..."
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured"
        echo ""
        echo "Please configure AWS credentials:"
        echo "  aws configure"
        exit 1
    fi
    
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    local region=$(aws configure get region)
    
    print_success "AWS credentials configured"
    echo "  Account ID: $account_id"
    echo "  Region: $region"
}

# Initialize Terraform
initialize_terraform() {
    local env=$1
    local env_dir="terraform/environments/$env"
    
    print_info "Initializing Terraform for environment: $env"
    
    if [ ! -d "$env_dir" ]; then
        print_error "Environment directory not found: $env_dir"
        exit 1
    fi
    
    cd "$env_dir"
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        if [ -f "terraform.tfvars.example" ]; then
            print_info "terraform.tfvars not found. Creating from example..."
            cp terraform.tfvars.example terraform.tfvars
            print_success "Created terraform.tfvars"
            echo ""
            print_info "Please edit terraform.tfvars with your configuration before proceeding"
            echo "  Edit: $env_dir/terraform.tfvars"
            exit 0
        else
            print_error "terraform.tfvars.example not found"
            exit 1
        fi
    fi
    
    # Initialize Terraform
    print_info "Running terraform init..."
    terraform init
    
    print_success "Terraform initialized successfully"
}

# Validate Terraform configuration
validate_terraform() {
    print_info "Validating Terraform configuration..."
    
    terraform validate
    
    print_success "Terraform configuration is valid"
}

# Plan infrastructure changes
plan_infrastructure() {
    print_info "Planning infrastructure changes..."
    
    terraform plan -out=tfplan
    
    print_success "Terraform plan created: tfplan"
    echo ""
    print_info "Review the plan above carefully"
    echo "To apply these changes, run:"
    echo "  terraform apply tfplan"
}

# Apply infrastructure
apply_infrastructure() {
    print_info "Applying infrastructure changes..."
    
    if [ ! -f "tfplan" ]; then
        print_error "No terraform plan found. Run 'terraform plan' first"
        exit 1
    fi
    
    terraform apply tfplan
    
    print_success "Infrastructure deployed successfully!"
    
    # Get outputs
    echo ""
    print_info "Cluster Information:"
    terraform output cluster_info
    
    echo ""
    print_info "Configure kubectl with:"
    terraform output -raw configure_kubectl
}

# Configure kubectl
configure_kubectl() {
    print_info "Configuring kubectl..."
    
    local cluster_name=$(terraform output -raw cluster_name)
    local region=$(terraform output -json cluster_info | jq -r '.region')
    
    aws eks update-kubeconfig --region "$region" --name "$cluster_name"
    
    print_success "kubectl configured successfully"
    
    # Test connection
    print_info "Testing cluster connection..."
    kubectl cluster-info
    
    print_success "Successfully connected to cluster"
}

# Main menu
show_menu() {
    echo ""
    echo "=========================================="
    echo "  SaaSInfraLab - EKS Platform Setup"
    echo "=========================================="
    echo ""
    echo "1. Check Prerequisites"
    echo "2. Initialize Terraform (dev)"
    echo "3. Validate Configuration"
    echo "4. Plan Infrastructure"
    echo "5. Apply Infrastructure"
    echo "6. Configure kubectl"
    echo "7. Full Setup (All Steps)"
    echo "8. Exit"
    echo ""
}

# Full setup
full_setup() {
    local env=${1:-dev}
    
    check_prerequisites
    check_aws_credentials
    initialize_terraform "$env"
    validate_terraform
    
    echo ""
    read -p "Ready to plan infrastructure? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        plan_infrastructure
        
        echo ""
        read -p "Apply this plan? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            apply_infrastructure
            configure_kubectl
            
            echo ""
            print_success "Setup complete!"
            echo ""
            echo "Next steps:"
            echo "1. Verify cluster: kubectl get nodes"
            echo "2. Deploy sample app: cd examples/quick-start && kubectl apply -f ."
            echo "3. Access Grafana: kubectl port-forward -n monitoring svc/grafana 3000:80"
        fi
    fi
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1) check_prerequisites ;;
            2) 
                read -p "Environment (dev/staging/production) [dev]: " env
                env=${env:-dev}
                initialize_terraform "$env"
                ;;
            3) validate_terraform ;;
            4) plan_infrastructure ;;
            5) apply_infrastructure ;;
            6) configure_kubectl ;;
            7) 
                read -p "Environment (dev/staging/production) [dev]: " env
                env=${env:-dev}
                full_setup "$env"
                ;;
            8) exit 0 ;;
            *) print_error "Invalid option" ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
else
    # Command line mode
    case "$1" in
        check)
            check_prerequisites
            check_aws_credentials
            ;;
        init)
            initialize_terraform "${2:-dev}"
            ;;
        validate)
            validate_terraform
            ;;
        plan)
            plan_infrastructure
            ;;
        apply)
            apply_infrastructure
            ;;
        kubectl)
            configure_kubectl
            ;;
        full)
            full_setup "${2:-dev}"
            ;;
        *)
            echo "Usage: $0 {check|init|validate|plan|apply|kubectl|full} [environment]"
            exit 1
            ;;
    esac
fi