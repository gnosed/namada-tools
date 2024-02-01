#!/bin/sh

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf "${GREEN}Setting up Namada installation...${NC}\n"

NAMADA_VERSION="v0.31.0"
BASE_URL="https://raw.githubusercontent.com/anoma/namada"
URL="${BASE_URL}/v${NAMADA_VERSION}/wasm/checksums.json"

printf "${YELLOW}Checking for available download tools...${NC}\n"
CHECK_CURL=$(command -v curl 2> /dev/null)
CHECK_WGET=$(command -v wget 2> /dev/null)

if [ -n "$CHECK_CURL" ]; then
    DOWNLOAD_CMD="curl -OL"
    printf "${GREEN}Using curl for downloading.${NC}\n"
elif [ -n "$CHECK_WGET" ]; then
    DOWNLOAD_CMD="wget -O"
    printf "${GREEN}Using wget for downloading.${NC}\n"
else
    printf "${RED}Neither curl nor wget are available on your system. Exiting...${NC}\n"
    exit 1
fi

printf "${YELLOW}Determining operating system...${NC}\n"
UNAME=$(uname)
if [ "$UNAME" = "Linux" ]; then
    OS="Linux"
    printf "${GREEN}Operating system identified as Linux.${NC}\n"
elif [ "$UNAME" = "Darwin" ]; then
    OS="Darwin"
    printf "${GREEN}Operating system identified as Darwin (macOS).${NC}\n"
else
    OS="linux" # default OS
    printf "${YELLOW}Operating system not identified. Defaulting to Linux.${NC}\n"
fi

printf "${YELLOW}Downloading Namada version ${NAMADA_VERSION} for ${OS}...${NC}\n"
$DOWNLOAD_CMD https://github.com/anoma/namada/releases/download/${NAMADA_VERSION}/namada-${NAMADA_VERSION}-${OS}-x86_64.tar.gz 

printf "${YELLOW}Extracting downloaded files...${NC}\n"
tar -xvf namada-${NAMADA_VERSION}-${OS}-x86_64.tar.gz

printf "${YELLOW}Installing Namada...${NC}\n"
sudo cp namada-${NAMADA_VERSION}-${OS}-x86_64/namada* /usr/local/bin

printf "${YELLOW}Removing downloaded files...${NC}\n"
rm -rf namada-${NAMADA_VERSION}-${OS}-x86_64 
rm namada-${NAMADA_VERSION}-${OS}-x86_64.tar.gz

printf "${GREEN}Namada installation completed with version:${NC}\n"
namada --version

