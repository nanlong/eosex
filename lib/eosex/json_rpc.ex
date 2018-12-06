defmodule Eosex.JsonRpc do
  alias Eosex.Client

  defmodule Wallet do
    @moduledoc """
    调用wallet的API，需要在本机或者服务器启动keosd服务。默认端口为8888，可以在启动时指定端口号。
    """

    @doc """
    创建钱包

    Args:
      * `wallet_name` - 钱包名称
    """
    def create(endpoint, wallet_name) do
      Client.request(endpoint <> "/v1/wallet/create", wallet_name)
    end

    @doc """
    打开钱包

    Args:
      * `wallet_name` - 钱包名称
    """
    def open(endpoint, wallet_name) do
      Client.request(endpoint <> "/v1/wallet/open", wallet_name)
    end

    @doc """
    锁定指定钱包

    Args:
      * `wallet_name` - 钱包名称
    """
    def lock(endpoint, wallet_name) do
      Client.request(endpoint <> "/v1/wallet/lock", wallet_name)
    end

    @doc """
    锁定所有钱包
    """
    def lock_all(endpoint) do
      Client.request(endpoint <> "/v1/wallet/lock_all")
    end

    @doc """
    解锁钱包

    Args:
      * `wallet_name` - 钱包名称
      * `wallet_password` - 钱包密码
    """
    def unlock(endpoint, wallet_name, wallet_password) do
      Client.request(endpoint <> "/v1/wallet/unlock", [wallet_name, wallet_password])
    end

    @doc """
    导入私钥到钱包

    Args:
      * `wallet_name` - 钱包名称
      * `private_key` - 私钥
    """
    def import_key(endpoint, wallet_name, private_key) do
      Client.request(endpoint <> "/v1/wallet/import_key", [wallet_name, private_key])
    end

    @doc """
    查看钱包列表
    """
    def list_wallets(endpoint) do
      Client.request(endpoint <> "/v1/wallet/list_wallets")
    end

    @doc """
    获取指定钱包中的公私钥对

    Args:
      * `wallet_name` - 钱包名称
      * `wallet_password` - 钱包密码
    """
    def list_keys(endpoint, wallet_name, wallet_password) do
      Client.request(endpoint <> "/v1/wallet/list_keys", [wallet_name, wallet_password])
    end

    @doc """
    签署交易
    """
    def sign_transaction(endpoint, txn, keys, id) do
      Client.request(endpoint <> "/v1/wallet/sign_transaction", [txn, keys, id])
    end

    @doc """
    获取所有钱包中的公钥
    """
    def get_public_keys(endpoint) do
      Client.request(endpoint <> "/v1/wallet/get_public_keys")
    end

    @doc """
    设置钱包的锁定时间，单位为秒

    Args:
      * `time` - 锁定时间，单位为秒
    """
    def set_timeout(endpoint, time) do
      Client.request(endpoint <> "/v1/wallet/set_timeout", time)
    end
  end

  defmodule Chain do

    @doc """
    获取区块链信息
    """
    def get_info(endpoint) do
      Client.request(endpoint <> "/v1/chain/get_info")
    end

    @doc """
    根据区块号或id获取区块详情

    Args:
      * `block_num_or_id` - 区块号或id
    """
    def get_block(endpoint, block_num_or_id) do
      Client.request(endpoint <> "/v1/chain/get_block", block_num_or_id: block_num_or_id)
    end

    @doc """
    未请求成功

    Args:
      * `block_num_or_id` - 区块号或id
    """
    def get_block_header_state(endpoint, block_num_or_id) do
      Client.request(endpoint <> "/v1/chain/get_block_header_state", block_num_or_id: block_num_or_id)
    end

    @doc """
    查询账号详情

    Args:
      * `account_name` - 账号名称
    """
    def get_account(endpoint, account_name) do
      Client.request(endpoint <> "/v1/chain/get_account", account_name: account_name)
    end

    @doc """
    查询账号接口详情

    Args:
      * `account_name` - 账号名称
    """
    def get_abi(endpoint, account_name) do
      Client.request(endpoint <> "/v1/chain/get_abi", account_name: account_name)
    end

    @doc """
    弃用

    Args:
      * `account_name` - 账号名称
    """
    def get_code(endpoint, account_name) do
      Client.request(endpoint <> "/v1/chain/get_code", account_name: account_name)
    end

    @doc """

    Args:
      * `account_name` - 账号名称
    """
    def get_raw_code_and_abi(endpoint, account_name) do
      Client.request(endpoint <> "/v1/chain/get_raw_code_and_abi", account_name: account_name)
    end

    @doc """
    查询智能合约数据

    Args:
      * ``scope - 账号名称
      * `code` - 智能合约名称
      * `table` - 表名称
      * `opts` - 选填字段
        * `json` - 是否返回json格式，默认：true
        * `lower_bound` - 上限，默认：0
        * `upper_bound` - 下限，默认：-1
        * `limit` - 数量，默认：10

    ## Examples:
      iex> Eosex.JsonRpc.Chain.get_table_rows("http://api.eosnewyork.io", "eosio", "eosio", "rammarket", json: false)
    """
    def get_table_rows(endpoint, scope, code, table, opts \\ []) do
      json = if is_nil(opts[:json]), do: true, else: opts[:json]
      lower_bound = opts[:lower_bound] || 0
      upper_bound = opts[:upper_bound] || -1
      limit = opts[:limit] || 10

      Client.request(
        endpoint <> "/v1/chain/get_table_rows",
        scope: scope,
        code: code,
        table: table,
        json: json,
        lower_bound: lower_bound,
        upper_bound: upper_bound,
        limit: limit
      )
    end

    @doc """
    指定代币合约，获取账户中该代币的余额

    Args:
      * `code` - 合约地址
      * `account` - 账号
      * `symbol` - 币种代码
    """
    def get_currency_balance(endpoint, code, account, symbol) do
      Client.request(endpoint <> "/v1/chain/get_currency_balance", code: code, account: account, symbol: symbol)
    end


    @doc """
    生成交易数据的bin字符串

    Args:
      * `transfer_info` ->
        %{
          code: ...,
          account: ...,
          args: %{...}
        }
    """
    def abi_json_to_bin(endpoint, transfer_info) do
      Client.request(endpoint <> "/v1/chain/abi_json_to_bin", transfer_info)
    end

    @doc """
    将bin字符串解析成json

    Args:
      * `code` - 合约地址
      * `account` - 账号
      * `binargs` - bin字符串
    """
    def abi_bin_to_json(endpoint, code, action, binargs) do
      Client.request(endpoint <> "/v1/chain/abi_bin_to_json", code: code, action: action, binargs: binargs)
    end

    @doc """
    根据交易信息和提供的公钥，筛选出本次交易需要使用的公钥

    Args:
      * `available_keys` - 公钥列表
      * `transaction` - 事务
    """
    def get_required_keys(endpoint, available_keys, transaction) do
      Client.request(endpoint <> "/v1/chain/get_required_keys", available_keys: available_keys, transaction: transaction)
    end

    @doc """
    获取某种资产的详情

    Args:
      * `code` - 发行人账户
      * `symbol` - 资产名称
    """
    def get_currency_stats(endpoint, code, symbol) do
      Client.request(endpoint <> "/v1/chain/get_currency_stats", code: code, symbol: symbol)
    end

    def get_producers() do

    end

    def push_block() do

    end

    @doc """
    将签署后的交易推送到区块链

    Args:
      * `transaction` -
      * `signatures` - 交易签名列表
    """
    def push_transaction(endpoint, transaction, signatures) do
      Client.request(endpoint <> "/v1/chain/push_transaction", transaction: transaction, signatures: signatures, compression: "none")
    end

    @doc """
    推送多个签署后的交易
    """
    def push_transactions() do

    end
  end

  defmodule History do
    @doc """
    获取账户的交易历史

    Args:
      * `account_name` - 账户
      * `post` -
      * `offset` -
    """
    def get_actions(endpoint, account_name, pos, offset) do
      Client.request(endpoint <> "/v1/history/get_actions", account_name: account_name, pos: pos, offset: offset)
    end

    @doc """
    获取交易详情

    Args:
      * `id` -  交易id
    """
    def get_transaction(endpoint, id) do
      Client.request(endpoint <> "/v1/history/get_transaction", id: id)
    end

    @doc """
    根据公钥查询账户

    Args:
      * `public_key` - 公钥
    """
    def get_key_accounts(endpoint, public_key) do
      Client.request(endpoint <> "/v1/history/get_key_accounts", public_key: public_key)
    end

    @doc """
    查询子账号

    Args:
      * `controlling_account` - 账号名
    """
    def get_controlled_accounts(endpoint, controlling_account) do
      Client.request(endpoint <> "/v1/history/get_controlled_accounts", controlling_account: controlling_account)
    end
  end
end
