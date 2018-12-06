defmodule Day06 do
  def run do
    points = read()

    points |> largest_finite_size() |> IO.puts()
    points |> safe_region_size(10000) |> IO.puts()
  end

  defp read do
    IO.read(:all)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split(", ")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def largest_finite_size(points) do
    {{min_x, min_y}, {max_x, max_y}} = calculate_min_max(points)

    grid =
      for y <- min_y..max_y, x <- min_x..max_x do
        points
        |> Enum.reduce({nil, nil}, fn {px, py}, {point, best} ->
          distance = abs(px - x) + abs(py - y)

          cond do
            distance > best -> {point, best}
            distance == best -> {nil, best}
            true -> {{px, py}, distance}
          end
        end)
        |> elem(0)
      end

    x_length = max_x - min_x + 1

    infinite_points =
      (Enum.take(grid, x_length) ++
         Enum.take(grid, -x_length) ++
         Enum.take_every(grid, x_length) ++
         Enum.take_every(Enum.drop(grid, max_x - min_x), x_length))
      |> Enum.uniq()
      |> MapSet.new()

    grid
    |> Enum.reject(&(&1 in infinite_points))
    |> Enum.reduce(%{}, fn point, counts -> Map.update(counts, point, 1, &(&1 + 1)) end)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  defp safe_region_size(points, max_distance) do
    {{min_x, min_y}, {max_x, max_y}} = calculate_min_max(points)

    for y <- min_y..max_y, x <- min_x..max_x do
      Enum.reduce(points, 0, fn {px, py}, acc -> acc + abs(px - x) + abs(py - y) end)
    end
    |> Enum.filter(&(&1 < max_distance))
    |> Enum.count()
  end

  defp calculate_min_max(points) do
    {x_points, y_points} = Enum.unzip(points)

    {min_x, max_x} = Enum.min_max(x_points)
    {min_y, max_y} = Enum.min_max(y_points)

    {{min_x, min_y}, {max_x, max_y}}
  end
end

Day06.run()
