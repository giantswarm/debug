#!/bin/bash

# Basic validation script to check for necessary tools for the Giant Swarm Debugging Environment

echo "Checking prerequisites for Giant Swarm Debugging Environment..."

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

check_command() {
	local cmd="$1"
	local purpose="$2"
	local install_hint="$3"
	local ver_arg="${4:---version}"

	echo -n "Checking for $cmd... "
	if command_exists "$cmd"; then
		echo "OK ($($cmd $ver_arg 2>&1 | head -n 1))"
		return 0
	else
		echo "NOT FOUND"
		echo "  Purpose: $purpose"
		echo "  Install hint: $install_hint"
		return 1
	fi
}

all_ok=1

# Essential Tools
check_command "kubectl" "Kubernetes CLI" "See https://kubernetes.io/docs/tasks/tools/install-kubectl/" "version" || all_ok=0
check_command "tsh" "Teleport Client" "See Giant Swarm internal docs or Teleport website" "version" || all_ok=0
check_command "go" "Go compiler (for envctl build)" "See https://go.dev/doc/install" "version" || all_ok=0

# MCP Server Dependencies
check_command "npm" "Node Package Manager (for mcp-server-kubernetes)" "Install Node.js from https://nodejs.org/" || all_ok=0
check_command "python" "Python (for prometheus-mcp-server)" "Install from https://www.python.org/downloads/" || all_ok=0
check_command "uv" "Python package manager (for prometheus-mcp-server)" "Install via pip: 'pip install uv' or see https://github.com/astral-sh/uv#installation" || all_ok=0

# Teleport Login Check
echo -n "Checking Teleport status... "
if tsh status >/dev/null 2>&1; then
	echo "OK (Logged in as $(tsh status | grep 'Logged in as' | awk '{print $4}'))"
else
	echo "NOT LOGGED IN or tsh status failed"
	echo "  Hint: Run 'tsh login --proxy=teleport.giantswarm.io'"
	all_ok=0
fi

# envctl Check (optional, checks common PATHs)
echo -n "Checking for envctl... "
if command_exists "envctl"; then
	echo "OK ($(envctl --version 2>&1))"
elif [ -f "./envctl" ]; then
	echo "OK (Found in current directory)"
else
	echo "NOT FOUND in PATH or current directory"
	echo "  Hint: Build or download from https://github.com/giantswarm/envctl and place in PATH"
	# Not failing the script for this one, as it might be run from the envctl dir
fi

echo "--------------------"
if [ $all_ok -eq 1 ]; then
	echo "All essential checks passed!"
	echo "Ensure you have configured mcp.json correctly (especially the Prometheus server path)."
	exit 0
else
	echo "Some checks failed. Please install the missing tools or log in to Teleport."
	exit 1
fi
