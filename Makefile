-include .env

build:; forge build
deploy-sepolia: 
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpcurl $(SEPOLI_RPC_URL) 
	--private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) 
	-vvv
.PHONY: update anvil deploy test test-zksync

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

snapshot:; forge snapshot

all: clean remove install update build

clean :; forge clean 

remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install

update:; forge update

anvil:;  anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

deploy:; forge script script/DeployStuff.s.sol:DeployStuff --broadcast --rpc-url http://localhost:8545  --private-key $(DEFAULT_ANVIL_KEY)   -vvvv 

interact:; forge script script/InteractWithStuff.s.sol:InteractWithStuff --broadcast --rpc-url http://localhost:8545  --private-key $(DEFAULT_ANVIL_KEY)   -vvvv 

zktest :; foundryup-zksync && forge test --zksync && foundryup

test :; forge test

anvil:; make anvil

