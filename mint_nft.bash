#!/bin/bash

cat << EOF
---------------------------------------------------
===================================================
CARDANO-NFT-MINTER
---------------------------------------------------
Make sure you are running your cardano-node before minting any nft.

You can use this guide here to run your cardano-node : https://developers.cardano.org/docs/get-started/running-cardano/

===================================================
---------------------------------------------------
EOF

echo Choose the cardano network where you will be minting the nft.
select TESTNETMAGIC in 'mainnet' 'testnet' 
do
break
done

case $TESTNETMAGIC in
mainnet) 
TESTNETMAGIC='764824073' # This id 764824073 is the mainnet magic. [ source : https://developers.cardano.org/docs/get-started/running-cardano/#mainnet--production ]
;;

testnet)
TESTNETMAGIC='1097911063' 
;;
esac

echo selected network with magic : $TESTNETMAGIC

read -p 'Enter token name (without space) : ' tokenname
read -p 'Enter token amount (usually 1): ' tokenamount
read -p 'Enter image ipfs cid : ' ipfs_cid
fee="300000" #placeholder fee : source = https://github.com/cardano-foundation/developer-portal/pull/283
output="0"

mkdir -p tokens
cd tokens
mkdir -p $tokenname
cd $tokenname

[[ -f payment.skey && -f payment.vkey ]] || $(cardano-cli address key-gen --verification-key-file payment.vkey --signing-key-file payment.skey && \
cardano-cli address build --payment-verification-key-file payment.vkey --out-file payment.addr --testnet-magic $TESTNETMAGIC) && echo generated payment keys

address=$(cat payment.addr)
echo ------------------------------------------------------
echo payment address = $address
echo Make sure you add some ada into this address. \
You can use the faucet here : https://testnets.cardano.org/en/testnets/cardano/tools/faucet/  to request for test Ada if you are on testnet
echo ------------------------------------------------------
echo ;echo;
read -p "After you have loaded some ada, Press Enter to continue : "

echo Showing Utxo transaction table
cardano-cli query utxo --address $address --testnet-magic $TESTNETMAGIC

echo;echo;
read -p "If you see your transaction, Press Enter to continue : "

echo Fetching protocol parameters into protocol.json
cardano-cli query protocol-parameters --testnet-magic $TESTNETMAGIC --out-file protocol.json

#create policy
mkdir -p policy

[[ -f policy/policy.vkey ]] || \
cardano-cli address key-gen \
    --verification-key-file policy/policy.vkey \
    --signing-key-file policy/policy.skey && \
    echo created policy/policy.vkey and policy/policy.skey

script="policy/policy.script"
touch $script
slotnumber=$(expr $(cardano-cli query tip --testnet-magic $TESTNETMAGIC | jq .slot?) + 10000)
echo calculated slotnumber = $slotnumber

echo creating policy script :
paymentKeyHash=$(cardano-cli address key-hash --payment-verification-key-file policy/policy.vkey)
cat << EOF > policy/policy.script 
{
  "type": "all",
  "scripts":
  [
   {
     "type": "before",
     "slot": $slotnumber
   },
   {
     "type": "sig",
     "keyHash": "$paymentKeyHash"
   }
  ]
}
EOF

echo created the below policy script : 
echo ------------------------------------------
cat policy/policy.script
echo ------------------------------------------
echo;echo;
read -p "Press Enter to continue : "
echo;echo;


cardano-cli query tip --testnet-magic $TESTNETMAGIC

cardano-cli transaction policyid --script-file ./policy/policy.script > policy/policyID
policyid=$(cat policy/policyID)
echo Generated policy id = $policyid

echo ; echo;
echo Generating metadata.json
policyid=$(cat policy/policyID)
cat << END > metadata.json
{
  "721": {
    "$policyid": {
      "$tokenname": {
        "description": "This is my first NFT thanks to the Cardano network",
        "name": "NFT token matadata property name",
        "id": "1",
        "image": ["ipfs://", "$ipfs_cid"]
      }
    }
  }
}
END

echo created the below metadata.json : 
echo ------------------------------------------
cat metadata.json
echo ------------------------------------------
echo ; echo;
read -p "Press Enter to continue : "


echo ; echo ; 
echo Building transaction
echo Here are all the details generated :
echo --------------------------------
echo fee=$fee
echo address=$address
echo output=$output
echo token amount=$tokenamount
echo policyid=$policyid
echo token name=$tokenname
echo slot number=$slotnumber
echo script=$script
echo --------------------------------

echo ; echo ; 
read -p 'Enter input transaction hash :' txhash 
read -p 'Enter transaction index (TxIx) :' txix
read -p 'Enter the current utxo amount (In lovelace) : ' funds

cardano-cli transaction build-raw \
--fee $fee  \
--tx-in $txhash#$txix  \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--mint="$tokenamount $policyid.$tokenname" \
--minting-script-file $script \
--metadata-json-file metadata.json  \
--invalid-hereafter $slotnumber \
--out-file matx.raw

fee=$(cardano-cli transaction calculate-min-fee --tx-body-file matx.raw --tx-in-count 1 --tx-out-count 1 --witness-count 2 --testnet-magic $TESTNETMAGIC --protocol-params-file protocol.json | cut -d " " -f1)
output=$(expr $funds - $fee)

echo ; echo ; 
echo calculated fees = $fee
echo calculated output = funds - fees = $output

echo ; echo ;
echo Building raw transaction based on new fees and output

cardano-cli transaction build-raw \
--fee $fee  \
--tx-in $txhash#$txix  \
--tx-out $address+$output+"$tokenamount $policyid.$tokenname" \
--mint="$tokenamount $policyid.$tokenname" \
--minting-script-file $script \
--metadata-json-file metadata.json  \
--invalid-hereafter $slotnumber \
--out-file matx.raw


echo ; echo ; 
echo Signing transaction
cardano-cli transaction sign  \
--signing-key-file payment.skey  \
--signing-key-file policy/policy.skey  \
--testnet-magic $TESTNETMAGIC --tx-body-file matx.raw  \
--out-file matx.signed


echo ; echo ; 
read -p 'Press Enter to submit the transaction to the network : '
echo Submitting the transaction to network
cardano-cli transaction submit --tx-file matx.signed --testnet-magic $TESTNETMAGIC

echo; echo;
echo Updated Utxo transaction table
cardano-cli query utxo --address $address --testnet-magic $TESTNETMAGIC
