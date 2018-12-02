defmodule Day01 do
  def run do
    ids = read_ids()

    IO.puts calculate_checksum(ids)
    IO.puts find_off_by_one(ids)
  end

  defp calculate_checksum(ids) do
    counts = ids |> Enum.reduce(%{}, fn id, counts ->
      id
      |> Enum.reduce(%{}, &count_occurrence_reducer/2)
      |> Map.values
      |> Enum.uniq
      |> Enum.reduce(counts, &count_occurrence_reducer/2)
    end)

    counts[2] * counts[3]
  end

  defp find_off_by_one(ids) do
    for(x <- ids, y <- ids, x != y, do: {x, y})
    |> Stream.map(fn {x, y} ->
      {
        length(x),
        Enum.zip(x, y) |> Enum.filter(fn {a, b} -> a == b end) |> Enum.map(&elem(&1, 0))
      }
    end)
    |> Stream.drop_while(fn {len, matching} -> length(matching) != len - 1 end)
    |> Enum.at(0)
    |> elem(1)
  end

  defp read_ids do
    IO.read(:all)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp count_occurrence_reducer(value, acc) do
    Map.update(acc, value, 1, &(&1 + 1))
  end
end

Day01.run
