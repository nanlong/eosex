# Eosex

启动命令行，设置钱包名称和密码

`WALLET_NAME=default WALLET_PASSWORD=PW5Kxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx iex -S mix`

### 1. 账号间转账

Args:
  * `node` - eos节点
  * `currency` - 币种信息
  * `from` - 转账发起人
  * `to` - 收款人
  * `quantity` - 数量
  * `memo` - 留言
  * `opts` - 选填字段
    * `public_key` - 公钥，如果没有填写则会在钱包内筛选所需公钥
    * `permission` - 权限，默认 active
    * `expiration` - 过期时间，默认1小时

#### Examples
```
iex> node = %{nodeos_endpoint: "http://127.0.0.1:8888", keosd_endpoint: "http://127.0.0.1:8889"}
iex> currency = %{code: "eosio.token", symbol: "EOS"}
iex> Eosex.transfer(node, currency, "eosio", "chainceoneos", 1.0000, "hi there")
```

### 2. 获取ram市场价

Args:
  * `node` - eos节点

#### Examples:
```
iex> node = %{nodeos_endpoint: "http://api.eosnewyork.io"}
iex> Eosex.ram_market(node)
```

### 3. 买入ram

Args:
  * `node` - eos节点
  * `payer` - 购买者账户名称
  * `receiver` - 接收者账户名称
  * `quant` - eos数量
  * `opts` - 选填字段
    * `public_key` - 公钥，如果没有填写则会在钱包内筛选所需公钥
    * `permission` - 权限，默认 active
    * `expiration` - 过期时间，默认1小时

#### Examples:
```
iex> node = %{nodeos_endpoint: "http://jungle2.cryptolions.io:80", keosd_endpoint: "http://127.0.0.1:8889"}
iex> Eosex.buy_ram(node, "testneteosex", "testneteosex", 1.0000)
```

### 4. 卖出ram

Args:
  * `node` - eos节点
  * `account` - 出售账号
  * `bytes` - 内存数量
  * `opts` - 选填字段
    * `public_key` - 公钥，如果没有填写则会在钱包内筛选所需公钥
    * `permission` - 权限，默认 active
    * `expiration` - 过期时间，默认1小时

#### Examples:
```
iex> node = %{nodeos_endpoint: "http://jungle2.cryptolions.io:80", keosd_endpoint: "http://127.0.0.1:8889"}
iex> Eosex.sell_ram(node, "testneteosex", 1024 * 50)
```

### 5. 抵押资源

Args:
  * `node` - eos节点
  * `from` - 抵押者账户名称
  * `receiver` - 接收者账户名称
  * `opts` - 可选参数
    * `stake_net_quantity` - 抵押的网络资源，二选一必填
    * `stake_cpu_quantity` - 抵押的cpu资源，二选一必填
    * `public_key` - 公钥，如果没有填写则会在钱包内筛选所需公钥
    * `permission` - 权限，默认 active
    * `expiration` - 过期时间，默认1小时
    * `transfer` - 0为租借，1为赠送，默认为0

## Examples:
```
iex> node = %{nodeos_endpoint: "http://jungle2.cryptolions.io:80", keosd_endpoint: "http://127.0.0.1:8889"}
iex> Eosex.delegatebw(node, "testneteosex", "testneteosex", stake_cpu_quantity: 1.0000)
```

### 6. 赎回资源

Args:
  * `node` - eos节点
  * `from` - 抵押者账户名称
  * `receiver` - 接收者账户名称
  * `opts` - 可选参数
    * `unstake_net_quantity` - 赎回的网络资源，二选一必填
    * `unstake_cpu_quantity` - 赎回的cpu资源，二选一必填
    * `public_key` - 公钥，如果没有填写则会在钱包内筛选所需公钥
    * `permission` - 权限，默认 active
    * `expiration` - 过期时间，默认1小时

#### Examples:
```
iex> node = %{nodeos_endpoint: "http://jungle2.cryptolions.io:80", keosd_endpoint: "http://127.0.0.1:8889"}
iex> Eosex.undelegatebw(node, "testneteosex", "testneteosex", unstake_cpu_quantity: 1.0000)
```
