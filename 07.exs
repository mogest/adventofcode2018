defmodule Day07 do
  @worker_count 5
  @completion_time_base 60

  def run do
    instructions = read()

    assemble_sleigh(instructions, 1)
    |> elem(0)
    |> IO.inspect()

    assemble_sleigh(instructions, @worker_count)
    |> elem(1)
    |> IO.inspect()
  end

  defp assemble_sleigh(instructions, worker_count) do
    path =
      instructions
      |> Enum.reduce(%{}, fn {a, b}, result ->
        Map.update(result, a, [b], &([b | &1] |> Enum.sort()))
      end)

    deps =
      instructions
      |> Enum.reduce(%{}, fn {a, b}, result ->
        Map.update(result, b, [a], &[a | &1])
      end)

    assemble_sleigh_tick(path, deps, make_workers(worker_count), [], 0)
  end

  defp make_workers(count) do
    List.duplicate({nil, 0}, count)
  end

  defp assemble_sleigh_tick(path, deps, workers, done, current_time) do
    {new_done, new_workers, new_current_time} = move_time_forward(done, workers, current_time)

    new_new_workers = assign_steps_to_free_workers(path, deps, new_workers, new_done)

    if all_workers_are_free?(new_new_workers) do
      {new_done |> Enum.join(), new_current_time}
    else
      assemble_sleigh_tick(path, deps, new_new_workers, new_done, new_current_time)
    end
  end

  defp all_workers_are_free?(workers) do
    Enum.all?(workers, fn {_, time} -> time == 0 end)
  end

  defp assign_steps_to_free_workers(path, deps, workers, done) do
    ready = calculate_ready(path, deps, done, workers)

    Enum.flat_map_reduce(workers, ready, fn
      {_, 0}, [next | rest] -> {[{next, completion_time(next)}], rest}
      worker, ready -> {[worker], ready}
    end)
    |> elem(0)
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
