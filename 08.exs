defmodule Day08 do
  def run do
    {root, []} = read() |> parse_node()

    metadata_sum(root) |> IO.puts()
    node_value(root) |> IO.puts()
  end

  defp metadata_sum({metadata, nodes}) do
    Enum.sum(metadata ++ Enum.map(nodes, &metadata_sum/1))
  end

  defp node_value({metadata, []}), do: Enum.sum(metadata)

  defp node_value({metadata, nodes}) do
    Enum.map(metadata, fn
      0 -> 0
      index when index > length(nodes) -> 0
      index -> node_value(Enum.at(nodes, index - 1))
    end)
    |> Enum.sum()
  end

  defp parse_node([child_node_count, metadata_count | rest]) do
    {nodes, remaining} = read_children(child_node_count, rest)
    {metadata, next} = Enum.split(remaining, metadata_count)
    {{metadata, nodes}, next}
  end

  defp read_children(0, data), do: {[], data}

  defp read_children(count, data) do
    {node, remaining} = parse_node(data)

    {subnodes, next} = read_children(count - 1, remaining)
    {[node | subnodes], next}
  end

  defp read do
    IO.read(:all)
    |> String.split(~r{\s+}, trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

Day08.run()
