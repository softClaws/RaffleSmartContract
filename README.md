## PlayFair3

**PlayFair3 is a Raffle smart contract build with solidity**

PlayFair3 consists of:

- **Multiple Players**: Allows multiple players to join the contract.
- **VRF(Varifiable Random Function)**: This is one of chaimlink features that generate a random number(s) that can be verified.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Raffle.s.sol:Raffle --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
