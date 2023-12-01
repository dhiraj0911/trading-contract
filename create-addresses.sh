#!/bin/sh

# Get chainId

# Define file path
file="./broadcast/Deploy.s.sol/421613/run-latest.json"

# Check if file exists
if [ ! -f "$file" ]; then
    echo "Unable to find file: $file"
    echo "pwd: $(pwd)"
    exit 1
fi

# Fetch the first element in the array
array_length=$(jq '.transactions | length' $file)
echo "Length of the 'transactions' array is: $array_length"
echo "Removing Contract Address .json" 
rm -f ./contractAddresses.json 

# Iterate over the "transactions" array
for i in $(seq 0 $((array_length-1))); do
    # Get the "transactionType" value of the current index
    num=`expr $i`
    transactionType=$(cat $file | jq -r '.transactions['$num'].transactionType')
    echo "transaction type is $transactionType"

    if echo "$transactionType" | grep -q "CREATE"; then
        contractNames=$(cat $file | jq -r '.transactions['$num'].contractName')
        contractAddresses=$(cat $file | jq -r '.transactions['$num'].contractAddress')
        echo "contract name is $contractNames and address is $contractAddresses"
        # fetching the Block Number from the receipt
        blockNumberHex=$(cat $file | jq -r '.receipts[0].blockNumber')
        echo "blockNumber in hex is: $blockNumberHex"
        
        blockNumberDecimal=$(echo $(($blockNumberHex)))
        echo "Block Number in decimal: $blockNumberDecimal"
        #Create contractAddresses.json file
        if ! [ -f "contractAddresses.json" ];
        then 
            echo "{" >> contractAddresses.json
        fi
        echo "\"$contractNames\":\"$contractAddresses\"," >> contractAddresses.json
        echo "contractAddresses.json created successfully"
    fi
    if [ $num -eq $((array_length-1)) ]; then
        echo "\"Testnet Version\": \"0.1\"," >> contractAddresses.json
        echo "\"Network\": \"Arbitrum Goerli\"" >> contractAddresses.json
        echo "}" >> contractAddresses.json 
    fi
done
