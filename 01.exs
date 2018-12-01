defmodule Day01 do
  def run do
    changes = read_changes()

    changes |> add |> IO.puts
    changes |> find_duplicate_frequency |> IO.puts
  end

  defp read_changes do
    IO.read(:all)
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  defp add(changes) do
    Enum.reduce(changes, 0, &+/2)
  end

  defp find_duplicate_frequency(changes) do
    changes
    |> Stream.cycle
    |> Stream.scan(0, &+/2)
    |> Enum.reduce_while(MapSet.new([0]), fn value, history ->
      if MapSet.member?(history, value), do: {:halt, value}, else: {:cont, MapSet.put(history, value)}
    end)
  end
end

Day01.run
