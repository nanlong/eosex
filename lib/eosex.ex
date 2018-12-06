defmodule Eosex do
  alias Eosex.JsonRpc.Wallet
  alias Eosex.JsonRpc.Chain
  alias Decimal, as: D

  # eos小数保留位数
  @eos_precision 4

  # 权限
  @tx_permission "active"

  # 过期时间，单位秒
  @tx_expiration 3600

  # 钱包名
  @wallet_name System.get_env("WALLET_NAME")

  # 钱包密码
  @wallet_password System.get_env("WALLET_PASSWORD")

  @doc """
  转账

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

  ## Examples
    iex> node = %{nodeos_endpoint: "http://127.0.0.1:8888", keosd_endpoint: "http://127.0.0.1:8889"}
    iex> currency = %{code: "eosio.token", symbol: "EOS", precision: 4}
    iex> Eosex.transfer(node, currency, "eosio", "chainceoneos", 1.0000, "hi there")
  """
  def transfer(node, currency, from, to, quantity, memo, opts \\ []) do
    # 交易信息
    transfer_info = gen_transfer(currency, from, to, quantity, memo)

    # 提交到链上
    send_to_chain(node, from, transfer_info, opts)
  end

  @doc """
  获取ram市场价

  Args:
    * `node` - eos节点

  ## Examples:
    iex> node = %{nodeos_endpoint: "http://api.eosnewyork.io"}
    iex> Eosex.ram_market(node)
  """
  def ram_market(node) do
    {:ok, data} = Chain.get_table_rows(node[:nodeos_endpoint], "eosio", "eosio", "rammarket")
    row = hd(data["rows"])
    {ram_balance, _} = Float.parse(row["base"]["balance"])
    {eos_balance, _} = Float.parse(row["quote"]["balance"])
    round(eos_balance / ram_balance * 1024, @eos_precision)
  end

  @doc """
  买入ram

  Args:
    * `node` - eos节点
    * `payer` - 购买者账户名称
    * `receiver` - 接收者账户名称
    * `quant` - eos数量
    * `opts` - 选填字段
      * `public_key` - 公钥，如果没有填写则会在钱包内筛选所需公钥
      * `permission` - 权限，默认 active
      * `expiration` - 过期时间，默认1小时

  ## Examples:
    iex> node = %{nodeos_endpoint: "http://jungle2.cryptolions.io:80", keosd_endpoint: "http://127.0.0.1:8889"}
    iex> Eosex.buy_ram(node, "testneteosex", "testneteosex", 1.0000)
  """
  def buy_ram(node, payer, receiver, quant, opts \\ []) do
    # 交易信息
    transfer_info = gen_transfer_buyram(payer, receiver, quant)

    # 提交到链上
    send_to_chain(node, payer, transfer_info, opts)
  end

  @doc """
  卖出ram

  Args:
    * `node` - eos节点
    * `account` - 出售账号
    * `bytes` - 内存数量
    * `opts` - 选填字段
      * `public_key` - 公钥，如果没有填写则会在钱包内筛选所需公钥
      * `permission` - 权限，默认 active
      * `expiration` - 过期时间，默认1小时

  ## Examples:
    iex> node = %{nodeos_endpoint: "http://jungle2.cryptolions.io:80", keosd_endpoint: "http://127.0.0.1:8889"}
    iex> Eosex.sell_ram(node, "testneteosex", 1024 * 50)
  """
  def sell_ram(node, account, bytes, opts \\ []) do
    # 交易信息
    transfer_info = gen_transfer_sellram(account, bytes)

    # 提交到链上
    send_to_chain(node, account, transfer_info, opts)
  end

  @doc """
  抵押资源

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
    iex> node = %{nodeos_endpoint: "http://jungle2.cryptolions.io:80", keosd_endpoint: "http://127.0.0.1:8889"}
    iex> Eosex.delegatebw(node, "testneteosex", "testneteosex", stake_cpu_quantity: 1.0000)
  """
  def delegatebw(node, from, receiver, opts \\ []) do
    if is_nil(opts[:stake_net_quantity] || opts[:stake_cpu_quantity]) do
      raise "required give `stake_net_quantity` or `stake_cpu_quantity`"
    end

    # 交易信息
    transfer_info = gen_transfer_delegatebw(from, receiver, opts)

    # 提交到链上
    send_to_chain(node, from, transfer_info, opts)
  end

  @doc """
  赎回资源

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

  ## Examples:
    iex> node = %{nodeos_endpoint: "http://jungle2.cryptolions.io:80", keosd_endpoint: "http://127.0.0.1:8889"}
    iex> Eosex.undelegatebw(node, "testneteosex", "testneteosex", unstake_cpu_quantity: 1.0000)
  """
  def undelegatebw(node, from, receiver, opts \\ []) do
    if is_nil(opts[:unstake_net_quantity] || opts[:unstake_cpu_quantity]) do
      raise "required give `unstake_net_quantity` or `unstake_cpu_quantity`"
    end

    # 交易信息
    transfer_info = gen_transfer_undelegatebw(from, receiver, opts)

    # 提交到链上
    send_to_chain(node, from, transfer_info, opts)
  end

  @doc """
  将交易发送到链上

  Args:
    * `node` - eos节点
    * `actor` - 操作账户
    * `transfer_info` - 交易信息
    * `opts` - 选填字段
      * `public_key` - 公钥，如果没有填写则会在钱包内筛选所需公钥
      * `permission` - 权限，默认 active
      * `expiration` - 过期时间，默认1小时
  """
  def send_to_chain(node, actor, transfer_info, opts \\ []) do
    # 将交易信息由JSON格式序列化为BIN格式字符串
    {:ok, %{"binargs" => binargs}} = Chain.abi_json_to_bin(node[:nodeos_endpoint], transfer_info)

    # 获取当前最新的区块编号
    {:ok, info} = Chain.get_info(node[:nodeos_endpoint])

    # 根据区块编号获取区块详情
    {:ok, block} = Chain.get_block(node[:nodeos_endpoint], info["head_block_id"])

    # 事务信息
    txn = gen_txn(actor, transfer_info, binargs, block, opts)

    # 公钥
    keys =
      if opts[:public_key] do
        # 使用传入的公钥
        [opts[:public_key]]
      else
        # 筛选出签署交易需要的公钥
        {:ok, %{"required_keys" => keys}} = required_keys(node, txn)
        keys
      end

    # 签署交易
    {:ok, signed_tx} = Wallet.sign_transaction(node[:keosd_endpoint], txn, keys, info["chain_id"])

    # 重新组合事务信息
    transaction = gen_transaction(signed_tx, txn)

    # 将签署后的交易推送到区块链
    Chain.push_transaction(node[:nodeos_endpoint], transaction, signed_tx["signatures"])
  end

  # 转账
  defp gen_transfer(currency, from, to, quantity, memo) do
    precision = currency[:precision] || @eos_precision

    %{
      code: currency[:code],
      action: "transfer",
      args: %{
        from: from,
        to: to,
        quantity: "#{round(quantity, precision, :down)} #{currency[:symbol]}",
        memo: memo
      }
    }
  end

  # 购买ram
  defp gen_transfer_buyram(payer, receiver, quant) do
    %{
      code: "eosio",
      action: "buyram",
      args: %{
        payer: payer,
        receiver: receiver,
        quant: "#{round(quant, @eos_precision, :down)} EOS"
      }
    }
  end

  # 出售ram
  defp gen_transfer_sellram(account, bytes) do
    %{
      code: "eosio",
      action: "sellram",
      args: %{
        account: account,
        bytes: bytes,
      }
    }
  end

  # 抵押资源
  defp gen_transfer_delegatebw(from, receiver, opts) do
    stake_net_quantity = "#{round(opts[:stake_net_quantity] || 0.0, @eos_precision, :down)} EOS"
    stake_cpu_quantity = "#{round(opts[:stake_cpu_quantity] || 0.0, @eos_precision, :down)} EOS"
    transfer = opts[:transfer] || 0

    %{
      code: "eosio",
      action: "delegatebw",
      args: %{
        from: from,
        receiver: receiver,
        stake_net_quantity: stake_net_quantity,
        stake_cpu_quantity: stake_cpu_quantity,
        transfer: transfer,
      }
    }
  end

  # 赎回资源
  defp gen_transfer_undelegatebw(from, receiver, opts) do
    unstake_net_quantity = "#{round(opts[:unstake_net_quantity] || 0.0, @eos_precision, :down)} EOS"
    unstake_cpu_quantity = "#{round(opts[:unstake_cpu_quantity] || 0.0, @eos_precision, :down)} EOS"

    %{
      code: "eosio",
      action: "undelegatebw",
      args: %{
        from: from,
        receiver: receiver,
        unstake_net_quantity: unstake_net_quantity,
        unstake_cpu_quantity: unstake_cpu_quantity,
      }
    }
  end

  defp gen_txn(actor, transfer_info, binargs, block, opts) do
    permission = opts[:permission] || @tx_permission
    expiration = gen_expiration(opts[:expiration] || @tx_expiration)

    %{
      ref_block_num: block["block_num"],
      ref_block_prefix: block["ref_block_prefix"],
      expiration: expiration,
      actions: [%{
        account: transfer_info[:code],
        name: transfer_info[:action],
        authorization: [%{
          actor: actor,
          permission: permission
        }],
        data: binargs,
      }],
      signatures: [],
    }
  end

  defp gen_transaction(signed_tx, txn) do
    %{
      ref_block_num: txn[:ref_block_num],
      ref_block_prefix: txn[:ref_block_prefix],
      expiration: txn[:expiration],
      actions: txn[:actions],
      context_free_actions: signed_tx["context_free_actions"],
      transaction_extensions: signed_tx["transaction_extensions"],
    }
  end

  defp gen_expiration(seconds) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(seconds, :second)
    |> NaiveDateTime.to_iso8601()
  end

  defp required_keys(node, txn) do
    if is_nil(@wallet_name) || is_nil(@wallet_password) do
      raise "required set WALLET_NAME and WALLET_PASSWORD on system env"
    end

    {:ok, keys} = Wallet.list_keys(node[:keosd_endpoint], @wallet_name, @wallet_password)
    public_keys = for [k, _] <- keys, do: k
    Chain.get_required_keys(node[:nodeos_endpoint], public_keys, txn)
  end

  defp round(number, precision, mode \\ :half_up)
  defp round(number, precision, mode) when is_float(number) do
    number
    |> D.from_float()
    |> round(precision, mode)
  end
  defp round(number, precision, mode) do
    number
    |> D.new()
    |> D.round(precision, mode)
    |> D.to_string()
  end
end
