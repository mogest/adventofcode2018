defmodule Entry do
  defstruct [:time, :event, :id]
end

# This is a bit terrible today :(

defmodule Day04 do
  def run do
    entries = read() |> parse()

    strategy_1(entries) |> IO.puts()
    strategy_2(entries) |> IO.puts()
  end

  defp read do
    IO.read(:all)
    |> String.split("\n", trim: true)
  end

  defp parse(lines) do
    lines
    |> Enum.sort()
    |> Enum.flat_map_reduce(0, fn line, last_id ->
      case Regex.run(~r{^\[(.+?)\] (Guard #(\d+)|falls|wakes)}, line) do
        [_, ts, _, id] -> {[%Entry{time: ts_to_time(ts), event: :awake, id: id}], id}
        [_, ts, "falls"] -> {[%Entry{time: ts_to_time(ts), event: :asleep, id: last_id}], last_id}
        [_, ts, "wakes"] -> {[%Entry{time: ts_to_time(ts), event: :awake, id: last_id}], last_id}
      end
    end)
    |> elem(0)
  end

  defp strategy_1(entries) do
    sleepiest =
      entries
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.filter(fn [start, _] -> start.event == :asleep end)
      |> Enum.reduce(%{}, fn [start, stop], log ->
        seconds = DateTime.diff(stop.time, start.time)
        Map.update(log, start.id, seconds, &(&1 + seconds))
      end)
      |> Enum.max_by(&elem(&1, 1))
      |> elem(0)

    minute = sleepiest_minute(entries, sleepiest) |> elem(0)

    String.to_integer(sleepiest) * minute
  end

  defp strategy_2(entries) do
    ids = entries |> Enum.map(& &1.id) |> Enum.uniq()

    {id, {minute, _}} =
      Enum.map(ids, &{&1, sleepiest_minute(entries, &1)})
      |> Enum.filter(fn {_, x} -> x end)
      |> Enum.max_by(fn {_, {_, n}} -> n end)

    String.to_integer(id) * minute
  end

  defp sleepiest_minute(entries, id) do
    entries
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.filter(fn [start, _] -> start.event == :asleep && start.id == id end)
    |> Enum.flat_map(fn [start, stop] ->
      start_unix = div(DateTime.to_unix(start.time), 60)
      stop_unix = div(DateTime.to_unix(stop.time), 60)

      minutes_between(start_unix, stop_unix)
    end)
    |> Enum.reduce(%{}, fn minute, minutes -> Map.update(minutes, minute, 1, &(&1 + 1)) end)
    |> Enum.sort_by(&elem(&1, 1))
    |> List.last()
  end

  defp ts_to_time(ts) do
    {:ok, time, 0} = DateTime.from_iso8601("#{ts}:00+00")
    time
  end

  defp minutes_between(start, stop) when start >= stop, do: []
  defp minutes_between(start, stop), do: [positive_rem(start, 60) | minutes_between(start + 1, stop)]

  def positive_rem(a, b) when a < 0, do: b + rem(a, b)
  def positive_rem(a, b), do: rem(a, b)
end

Day04.run()
