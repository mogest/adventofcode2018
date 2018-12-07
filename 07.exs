defmodule Day07 do
  @worker_count 5
  @completion_time_base 60

  def run do
    instructions = read()

    path =
      instructions
      |> Enum.reduce(%{}, fn {a, b}, result ->
        Map.update(result, a, [b], &([b | &1] |> Enum.sort()))
      end)

    dependencies =
      instructions
      |> Enum.reduce(%{}, fn {a, b}, result ->
        Map.update(result, b, [a], &[a | &1])
      end)

    assemble_sleigh(path, dependencies, make_workers(1))
    |> elem(0)
    |> IO.inspect()

    assemble_sleigh(path, dependencies, make_workers(@worker_count))
    |> elem(1)
    |> IO.inspect()
  end

  defp make_workers(count) do
    List.duplicate({nil, 0}, count)
  end

  defp assemble_sleigh(path, deps, workers, done \\ [], current_time \\ 0) do
    {new_done, new_workers, new_current_time} = move_time_forward(done, workers, current_time)

    ready = calculate_ready(path, deps, new_done, new_workers)

    {new_new_workers, _} =
      Enum.flat_map_reduce(new_workers, ready, fn
        {_, 0}, [next | rest] -> {[{next, completion_time(next)}], rest}
        worker, ready -> {[worker], ready}
      end)

    if Enum.all?(new_new_workers, fn {_, time} -> time == 0 end) do
      {new_done |> Enum.join(), new_current_time}
    else
      assemble_sleigh(path, deps, new_new_workers, new_done, new_current_time)
    end
  end

  defp move_time_forward(done, workers, current_time) do
    running_timers =
      workers
      |> Enum.filter(fn {_, time} -> time > 0 end)
      |> Enum.map(&elem(&1, 1))

    if Enum.empty?(running_timers) do
      {done, workers, current_time}
    else
      lowest_time = running_timers |> Enum.min()

      finished_steps =
        Enum.filter(workers, fn {_, time} -> time == lowest_time end)
        |> Enum.map(&elem(&1, 0))

      new_workers =
        Enum.map(workers, fn {step, time} ->
          {step, if(time == 0, do: 0, else: time - lowest_time)}
        end)

      new_current_time = current_time + lowest_time
      new_done = done ++ finished_steps

      {new_done, new_workers, new_current_time}
    end
  end

  defp completion_time(step) do
    <<v::utf8>> = step
    v - 64 + @completion_time_base
  end

  defp calculate_ready(path, deps, done, workers) do
    start_ready =
      deps
      |> Enum.flat_map(fn {a, _} -> traverse(deps, a) end)
      |> Enum.uniq()

    done_ready =
      Enum.flat_map(done, fn step ->
        Map.get(path, step, [])
        |> Enum.filter(fn a -> Enum.all?(deps[a], &(&1 in done)) end)
      end)

    in_progress =
      Enum.flat_map(workers, fn
        {_, 0} -> []
        {step, _} -> [step]
      end)

    (start_ready ++ done_ready)
    |> Enum.uniq()
    |> Enum.reject(fn step -> step in done or step in in_progress end)
    |> Enum.sort()
  end

  defp traverse(tree, a) do
    if tree[a] do
      Enum.flat_map(tree[a], &traverse(tree, &1))
    else
      [a]
    end
  end

  defp read do
    IO.read(:all)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [_, a, b] = Regex.run(~r{Step ([A-Z]).+([A-Z])}, line)
    {a, b}
  end
end

Day07.run()
