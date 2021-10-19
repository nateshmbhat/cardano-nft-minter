# cardano-nft-minter
### A script that handles minting cardano NFT tokens in a self contained and interactive way.

Script includes options to : 
- Choose the cardano network (testnet or mainnet)
- Necessary prompts to enter information like : 
    - NFT Image IPFS CID to be used for NFT
    - Token name and amount
    - Input UTXO transaction hash and index
- Appropriate prompts and links
- Appropriate messages at every step to help you see the progress of the minting process
- Shows the contents of some key files that are created during minting for reviewing


## Sample Run : 

```
❯ ./mint_nft.bash
---------------------------------------------------
===================================================
CARDANO-NFT-MINTER
---------------------------------------------------
Make sure you are running your cardano-node before minting any nft.

You can use this guide here to run your cardano-node : https://developers.cardano.org/docs/get-started/running-cardano/

===================================================
---------------------------------------------------
Choose the cardano network where you will be minting the nft.
1) mainnet
2) testnet
#? 2
selected network with magic : 1097911063
Enter token name (without space) : MyWonderfulToken
Enter token amount (usually 1): 1
Enter image ipfs cid : bafybeieqtapfecmv6xumax5yfxdamdt5m7l4yply25icqgfmexyxcgr7t4
generated payment keys
------------------------------------------------------
payment address = addr_test1vpxdnspg9varqd7fg4tdxl3gdn2avdcta50stvnay8fw22qxmq307
Make sure you add some ada into this address. You can use the faucet here : https://testnets.cardano.org/en/testnets/cardano/tools/faucet/ to request for test Ada if you are on testnet
------------------------------------------------------
After you have loaded some ada, Press Enter to continue :
Showing Utxo transaction table
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
4b061c2d7e5c2262cbe48412d70b80a12f5cf5bd3ec8af18524f8af73778c578     0        1000000000 lovelace + TxOutDatumHashNone

If you see your transaction, Press Enter to continue :
Fetching protocol parameters into protocol.json
created policy/policy.vkey and policy/policy.skey
calculated slotnumber = 40272443
creating policy script :
created the below policy script :
------------------------------------------
{
  "type": "all",
  "scripts":
  [
   {
     "type": "before",
     "slot": 40272443
   },
   {
     "type": "sig",
     "keyHash": "ed6f3e2144d70e839d8701f23ebcca229bcfde8e1d6b7838bda11ac8"
   }
  ]
}
------------------------------------------
Press Enter to continue :
{
    "epoch": 163,
    "hash": "1af5a2c59b82cbd5f0148212d533111a981acbc486296eb086de6f51f83f8601",
    "slot": 40262443,
    "block": 3003729,
    "era": "Alonzo",
    "syncProgress": "100.00"
}
Generated policy id = 07a159beabe88c6fea4274e622ba860d54618b3116e7420528000ec3


Generating metadata.json
created the below metadata.json :
------------------------------------------
{
  "721": {
    "07a159beabe88c6fea4274e622ba860d54618b3116e7420528000ec3": {
      "MyWonderfulToken": {
        "description": "This is my first NFT thanks to the Cardano network",
        "name": "NFT token matadata property name",
        "id": "1",
        "image": ["ipfs://", "bafybeieqtapfecmv6xumax5yfxdamdt5m7l4yply25icqgfmexyxcgr7t4"]
      }
    }
  }
}
------------------------------------------

Press Enter to continue :


Building transaction
Here are all the details generated :
--------------------------------
fee=0
address=addr_test1vpxdnspg9varqd7fg4tdxl3gdn2avdcta50stvnay8fw22qxmq307
output=0
token amount=1
policyid=07a159beabe88c6fea4274e622ba860d54618b3116e7420528000ec3
token name=MyWonderfulToken
slot number=40272443
script=policy/policy.script
--------------------------------

Enter input transaction hash :4b061c2d7e5c2262cbe48412d70b80a12f5cf5bd3ec8af18524f8af73778c578
Enter transaction index (TxIx) :0
Enter the current utxo amount (In lovelace) : 1000000000

calculated fees = 196213
calculated output = funds - fees = 999803787


Building raw transaction based on new fees and output
Signing transaction
Press Enter to submit the transaction to the network :
Submitting the transaction to network
Transaction successfully submitted.

Updated Utxo transaction table
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
1ddc165e2b8a4a2efb382ffec792d2d483bebe2e96d8c23b09413557e9932a11     0        999803787 lovelace + 1 07a159beabe88c6fea4274e622ba860d54618b3116e7420528000ec3.MyWonderfulToken + TxOutDatumHashNone
```