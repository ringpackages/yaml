// Example 8: Working with large YAML files
// This example demonstrates loading and accessing a larger configuration file

load "yaml.ring"

? "Example 8: Working with large YAML configuration files"

// Load the large YAML file
data = yaml_load("08-large-data.yaml")

if (isNull(data)) {
	? "Error loading large YAML file!"
	? "Last error: " + yaml_lasterror()
else
	? "Successfully loaded large YAML file"

	// Extract application information
	appName = yaml_get(data, "application.name")
	appVersion = yaml_get(data, "application.version")
	appDescription = yaml_get(data, "application.description")

	? nl + "Application Information:"
	? "  Name: " + appName
	? "  Version: " + appVersion
	? "  Description: " + appDescription

	// Access server configurations
	? nl + "Database Server Configuration:"
	dbHost = yaml_get(data, "servers.[1].host")
	dbType = yaml_get(data, "servers.[1].type")
	dbName = yaml_get(data, "servers.[1].database.name")

	? "  Host: " + dbHost
	? "  Type: " + dbType
	? "  Database: " + dbName

	// Access API server endpoints
	? nl + "API Endpoints (Server 1):"
	endpoint1Path = yaml_get(data, "servers.[2].endpoints.[1].path")
	endpoint1Methods = yaml_get(data, "servers.[2].endpoints.[1].methods")
	endpoint1Auth = yaml_get(data, "servers.[2].endpoints.[1].authentication")

	? "  Path: " + endpoint1Path
	? "  Methods: " + print(endpoint1Methods)
	? "  Authentication: " + endpoint1Auth

	// Access permissions for roles
	? nl + "Role Permissions:"

	// Admin permissions (get as array)
	adminPerms = yaml_get(data, "permissions.admin")
	if (isList(adminPerms)) {
		? "  Admin permissions: "
		for perm in adminPerms {
			? "    - " + perm
		}
	}

	// Manager permissions
	managerPerms = yaml_get(data, "permissions.manager")
	if isList(managerPerms) {
		? "  Manager permissions: "
		for perm in managerPerms {
			? "    - " + perm
		}
	}

	// Access deployment configuration
	? nl + "Deployment Configuration:"
	k8sNamespace = yaml_get(data, "deployment.kubernetes.namespace")
	apiReplicas = yaml_get(data, "deployment.kubernetes.replicas.api")
	dbReplicas = yaml_get(data, "deployment.kubernetes.replicas.db")

	? "  Kubernetes namespace: " + k8sNamespace
	? "  API replicas: " + apiReplicas
	? "  DB replicas: " + dbReplicas

	// Access environment variables (partial examples)
	? nl + "Environment Variables:"
	nodeEnv = yaml_get(data, "environment_variables.NODE_ENV")
	databaseUrl = yaml_get(data, "environment_variables.DATABASE_URL")

	? "  NODE_ENV: " + nodeEnv
	? "  DATABASE_URL: " + databaseUrl

	// Access monitoring configuration
	? nl + "Monitoring Setup:"
	promEnabled = yaml_get(data, "deployment.monitoring.prometheus.enabled")
	promScrape = yaml_get(data, "deployment.monitoring.prometheus.scrape_interval")
	grafanaEnabled = yaml_get(data, "deployment.monitoring.grafana.enabled")

	? "  Prometheus enabled: " + promEnabled
	? "  Scrape interval: " + promScrape
}

? nl + "Done!"