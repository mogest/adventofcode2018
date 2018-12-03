defmodule Claim do
  defstruct [:id, :x, :y, :w, :h]

  def from([id, x, y, w, h]) do
    %Claim{id: id, x: x, y: y, w: w, h: h}
  end

  def cells(claim) do
    for x <- claim.x..(claim.x + claim.w - 1),
        y <- claim.y..(claim.y + claim.h - 1),
        do: y * 1000 + x
  end
end

defmodule Day03 do
  def run do
    claims = read_claims()

    overlapping_cell_count(claims) |> IO.puts()
    non_overlapping_claim_ids(claims) |> IO.inspect()
  end

  defp overlapping_cell_count(claims) do
    claims
    |> Enum.flat_map(&Claim.cells/1)
    |> Enum.reduce(%{}, fn cell, map -> Map.update(map, cell, 1, &(&1 + 1)) end)
    |> Map.values()
    |> Enum.filter(fn v -> v > 1 end)
    |> Enum.count()
  end

  defp non_overlapping_claim_ids(claims) do
    all_claim_ids = claims |> Enum.map(& &1.id) |> MapSet.new()
    overlapped_ids = overlapping_claim_ids(claims)

    MapSet.difference(all_claim_ids, overlapped_ids) |> Enum.to_list()
  end

  defp overlapping_claim_ids(claims) do
    claims
    |> Enum.reduce({MapSet.new(), %{}}, fn claim, {overlapped, cloth} ->
      Claim.cells(claim)
      |> Enum.reduce({overlapped, cloth}, fn cell, {overlapped, cloth} ->
        if value = Map.get(cloth, cell) do
          {overlapped |> MapSet.put(value) |> MapSet.put(claim.id), cloth}
        else
          {overlapped, Map.put(cloth, cell, claim.id)}
        end
      end)
    end)
    |> elem(0)
  end

  defp read_claims do
    IO.read(:all)
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, ~r{\D+}, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Claim.from()
    end)
  end
end

Day03.run()
