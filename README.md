## 项目简介

本仓库包含基于 Gnosis Safe 的 `SafeProxyFactory` 合约，以及 Polymarket 方案中使用的 `ConditionalTokens` 与 `FallbackHandler` 等合约。

我们提供了一个 Foundry 脚本，用于在 Arbitrum Sepolia 等网络上一键部署以下合约：

- **FallbackHandler**
- **GnosisSafeL2**（作为 Safe 的 master copy）
- **SafeProxyFactory**（构造参数中的 `masterCopy` 为上一步部署出的 `GnosisSafeL2` 地址）
- **ConditionalTokens**
- **MultiSend**（用于 Safe 的批量交易执行）

脚本会在终端输出每个合约的部署地址，Forge 在 `--broadcast -vvvv` 模式下也会输出对应交易哈希，方便记录。

## 环境准备

- **安装 Foundry**：参考官方文档 [`https://book.getfoundry.sh`](https://book.getfoundry.sh)
- **设置环境变量**（示例，以 Arbitrum Sepolia 为例）：

```shell
export RPC_URL_ARBITRUM_SEPOLIA="https://lb.drpc.live/arbitrum-sepolia/<your_token>"
export DEPLOYER_PRIVATE_KEY="0x你的私钥（不带空格）"
```

> **注意**：私钥务必只用于测试网账户，并妥善保管，不要提交到版本库。

## 使用 Foundry 脚本部署合约

部署脚本位于 `script/DeployPolymarketContracts.s.sol`，脚本合约名为 `DeployPolymarketContracts`。

在项目根目录执行：

```shell
forge script script/DeployPolymarketContracts.s.sol:DeployPolymarketContracts \
  --rpc-url $RPC_URL_ARBITRUM_SEPOLIA \
  --broadcast -vvvv
```

脚本执行完成后，你将在终端中看到类似输出（示意）：

```text
FallbackHandler deployed at 0x...
GnosisSafeL2 (masterCopy) deployed at 0x...
SafeProxyFactory deployed at 0x...
ConditionalTokens deployed at 0x...
MultiSend deployed at 0x...
```

Forge 会在 `-vvvv` 模式下同时打印每一笔部署交易的 `transaction hash`，可以从日志中直接复制保存。

## 合约验证命令示例

以下示例以 Arbitrum Sepolia（`chain-id = 421614`）为例，使用 Arbiscan 作为验证服务。请替换其中的占位内容：

- `<ARBISCAN_API_KEY>`：你的 Arbiscan API Key
- `<FALLBACK_HANDLER_ADDRESS>`：部署得到的 `FallbackHandler` 地址
- `<GNOSIS_SAFE_L2_ADDRESS>`：部署得到的 `GnosisSafeL2` 地址
- `<SAFE_PROXY_FACTORY_ADDRESS>`：部署得到的 `SafeProxyFactory` 地址
- `<CONDITIONAL_TOKENS_ADDRESS>`：部署得到的 `ConditionalTokens` 地址
- `<MULTI_SEND_ADDRESS>`：部署得到的 `MultiSend` 地址

### 验证 FallbackHandler

```shell
forge verify-contract \
  --chain-id 421614 \
  --verifier etherscan \
  --etherscan-api-key <ARBISCAN_API_KEY> \
  <FALLBACK_HANDLER_ADDRESS> \
  FallbackHandler
```

### 验证 GnosisSafeL2（masterCopy）

```shell
forge verify-contract \
  --chain-id 421614 \
  --verifier etherscan \
  --etherscan-api-key <ARBISCAN_API_KEY> \
  <GNOSIS_SAFE_L2_ADDRESS> \
  GnosisSafeL2
```

### 验证 SafeProxyFactory

```shell
forge verify-contract \
  --chain-id 421614 \
  --verifier etherscan \
  --etherscan-api-key <ARBISCAN_API_KEY> \
  <SAFE_PROXY_FACTORY_ADDRESS> \
  SafeProxyFactory
```

> 如果验证失败，可以根据 Arbiscan 的提示，补充 `--constructor-args` 或 `--constructor-args-path`，将 `masterCopy` 与 `fallbackHandler` 的构造参数按实际部署情况编码传入。

### 验证 ConditionalTokens

```shell
forge verify-contract \
  --chain-id 421614 \
  --verifier etherscan \
  --etherscan-api-key <ARBISCAN_API_KEY> \
  <CONDITIONAL_TOKENS_ADDRESS> \
  ConditionalTokens
```

### 验证 MultiSend

```shell
forge verify-contract \
  --chain-id 421614 \
  --verifier etherscan \
  --etherscan-api-key <ARBISCAN_API_KEY> \
  <MULTI_SEND_ADDRESS> \
  MultiSend
```

## 其他常用命令

- **编译合约**

```shell
forge build
```

- **运行测试**

```shell
forge test
```

- **格式化代码**

```shell
forge fmt
```

