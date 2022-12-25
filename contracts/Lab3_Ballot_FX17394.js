(async () => {
  try {
    console.log('deploy...')

    // Note that the script needs the ABI which is generated from the compilation artifact.
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', 'contracts/artifacts/Lab3_Ballot_FX17394.json'))
    const accounts = await web3.eth.getAccounts()

    let contract = new web3.eth.Contract(metadata.abi)

    contract = contract.deploy({
      data: metadata.data.bytecode.object,
      arguments: [["0x426964656e000000000000000000000000000000000000000000000000000000","0x7472756d70000000000000000000000000000000000000000000000000000000"]]
    })

    newContractInstance = await contract.send({
      from: accounts[0],
      gas: 1500000,
      gasPrice: '30000000000'
    })
    console.log(newContractInstance.options.address)
    console.log('deployed!')

  } catch (e) {
    console.log(e.message)
  }
})()