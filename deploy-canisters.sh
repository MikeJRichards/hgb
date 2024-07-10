#!/bin/sh

# REQUIREMENTS
# - on another tab you already did "dfx start" (--clean)

# HOW TO RUN:
# Run the following command: npm run local

dfx deploy sale
dfx deploy exchange
dfx deploy property_database
dfx deploy HGB_token
dfx deploy LNFT
dfx deploy hgb_frontend

echo ""
echo "Finished Deploy Local Script"
echo ""