#!/bin/bash
# Simple start script for local development

# Activate virtual environment if it exists
if [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# Set Python path to include the current directory
export PYTHONPATH=$PYTHONPATH:$(pwd)

# Run the application
python main.py
