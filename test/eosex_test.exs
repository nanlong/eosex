defmodule EosexTest do
  use ExUnit.Case
  doctest Eosex

  test "greets the world" do
    assert Eosex.hello() == :world
  end
end
