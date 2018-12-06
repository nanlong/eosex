defmodule Eosex.Numeric do
  use Bitwise

  @base64_chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  def create_base64_map() do
    charlist = String.to_charlist(@base64_chars)

    (for _ <- 1..256, do: -1)
    |> Enum.with_index()
    |> Enum.map(fn {item, index} ->
      cond do
        index in charlist -> index
        index == Enum.at(String.to_charlist("="), 0) -> 0
        true -> item
      end
    end)
  end

  def base64_to_binary(s) do
    len = String.length(s)

    len =
      if (len &&& 3) == 1 && String.ends_with?(s, "=") do
        len - 1
      else
        len
      end

    if (len &&& 3) != 0 do
      raise "base-64 value is not padded correctly"
    end

    groups = len >>> 2
    bytes = groups * 3

    bytes =
      cond do
        len > 0 && String.ends_with?(s, "==") -> bytes - 2
        len > 0 && String.ends_with?(s, "=") -> bytes - 1
        true -> bytes
      end

    base64_map = create_base64_map()
    s_charlist = String.to_charlist(s)
    result = for _ <- 1..bytes, do: 0

    (0..groups - 1)
    |> Enum.to_list()
    |> Enum.reduce(result, fn group, acc ->
      digit0 = Enum.at(base64_map, Enum.at(s_charlist, group * 4 + 0))
      digit1 = Enum.at(base64_map, Enum.at(s_charlist, group * 4 + 1))
      digit2 = Enum.at(base64_map, Enum.at(s_charlist, group * 4 + 2))
      digit3 = Enum.at(base64_map, Enum.at(s_charlist, group * 4 + 3))

      result = List.update_at(acc, group * 3 + 0, fn _ -> (digit0 <<< 2) ||| (digit1 >>>4) end)

      result =
        if group * 3 + 1 < bytes do
          List.update_at(result, group * 3 + 1, fn _ -> ((digit1 &&& 15) <<< 4) ||| (digit2 >>> 2) end)
        else
          result
        end

      result =
        if group * 3 + 2 < bytes do
          List.update_at(result, group * 3 + 2, fn _ -> ((digit2 &&& 3) <<< 6) ||| digit3 end)
        else
          result
        end

      result
    end)
  end
end
