defmodule Day05 do
  use Bitwise

  # This is a good example of a challenge where immutable data structures are
  # not the right choice.  Doesn't take too long to run but it would be
  # so so much faster using mutable ones.  Unless I'm missing something?

  def run do
    polymer = read()

    fully_reacted_length(polymer) |> IO.puts()

    shortest_reacted_length_post_removal(polymer) |> IO.puts()
  end

  defp shortest_reacted_length_post_removal(polymer) do
    polymer
    |> all_units_in_polymer
    |> Enum.map(fn reject_unit ->
      polymer
      |> Enum.reject(&(&1 == reject_unit or &1 == (reject_unit ||| 32)))
      |> fully_reacted_length
    end)
    |> Enum.min()
  end

  defp all_units_in_polymer(polymer) do
    polymer |> Enum.map(&(&1 &&& 223)) |> Enum.uniq()
  end

  defp fully_reacted_length(polymer) do
    polymer
    |> Stream.unfold(fn polymer ->
      reacted_polymer = react(polymer)
      if reacted_polymer != polymer, do: {reacted_polymer, reacted_polymer}
    end)
    |> Stream.map(&length/1)
    |> Enum.to_list()
    |> List.last()
  end

  defp react(polymer) do
    polymer
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map_reduce(false, fn
      _, true -> {[], false}
      [a], false -> {[a], false}
      [a, b], false when a != b and (a &&& 223) == (b &&& 223) -> {[], true}
      [a, _], false -> {[a], false}
    end)
    |> elem(0)
  end

  defp read do
    IO.read(:all) |> String.trim() |> String.to_charlist()
  end
end

Day05.run()
