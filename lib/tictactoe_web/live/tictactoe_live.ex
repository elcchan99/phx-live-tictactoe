defmodule TictactoeWeb.TictactoeLive do
  use TictactoeWeb, :live_view

  @empty -1
  @p1 0
  @p2 1
  @players %{@empty => "", @p1 => "X", @p2 => "O"}
  @gamestate_ing "continue"
  @gamestate_p1 @p1
  @gamestate_p2 @p2
  @gamestate_draw "draw"

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(initial_game())

    {:ok, socket}
  end

  defp initial_game() do
    %{
      board: Enum.map(1..9, fn _ -> -1 end),
      players: @players,
      next_player: @p1,
      game_state: @gamestate_ing,
      win_state: expand_win_state([])
    }
  end

  @impl true
  def handle_event(
        "move",
        %{"cell" => cell_id},
        %{assigns: %{game_state: @gamestate_ing}} = socket
      ) do
    socket =
      socket
      |> move(cell_id)
      |> update_game_state()

    {:noreply, socket}
  end

  @impl true
  def handle_event("move", _params, socket) do
    IO.puts("Game already ended")
    {:noreply, socket}
  end

  defp move(socket, cell_id) when not is_integer(cell_id) do
    {cell_id_int, _} = Integer.parse(cell_id)
    move(socket, cell_id_int)
  end

  defp move(%{assigns: %{board: board, next_player: player}} = socket, cell_id) do
    case Enum.at(socket.assigns.board, cell_id) do
      @empty ->
        socket
        |> assign(board: board |> List.update_at(cell_id, fn _ -> player end))
        |> assign(next_player: next_player(player))

      _ ->
        IO.puts("Cell #{cell_id} is already occupied.")
        socket
    end
  end

  defp next_player(current_player), do: rem(current_player + 1, 2)

  defp update_game_state(%{assigns: %{board: board}} = socket) do
    {new_game_state, win_state} = cal_game_state(board)

    socket
    |> assign(game_state: new_game_state)
    |> assign(win_state: expand_win_state(win_state))
  end

  defp cal_game_state(board) do
    case has_won(board) do
      {@p1, win_state} ->
        IO.puts("P1 wins!")
        {@gamestate_p1, win_state}

      {@p2, win_state} ->
        IO.puts("P2 wins!")
        {@gamestate_p2, win_state}

      {nil, _} ->
        if is_drawn(board) do
          {@gamestate_draw, []}
        else
          {@gamestate_ing, []}
        end
    end
  end

  defp has_won(board) do
    case board do
      # horizontals
      [@p1, @p1, @p1 | _] -> {@p1, [0, 1, 2]}
      [@p2, @p2, @p2 | _] -> {@p2, [0, 1, 2]}
      [_, _, _, @p1, @p1, @p1 | _] -> {@p1, [3, 4, 5]}
      [_, _, _, @p2, @p2, @p2 | _] -> {@p2, [3, 4, 5]}
      [_, _, _, _, _, _, _, _, @p1, @p1, @p1] -> {@p1, [6, 7, 8]}
      [_, _, _, _, _, _, _, _, @p2, @p2, @p2] -> {@p2, [6, 7, 8]}
      # verticals
      [@p1, _, _, @p1, _, _, @p1, _, _] -> {@p1, [0, 3, 6]}
      [@p2, _, _, @p2, _, _, @p2, _, _] -> {@p2, [0, 3, 6]}
      [_, @p1, _, _, @p1, _, _, @p1, _] -> {@p1, [1, 4, 7]}
      [_, @p2, _, _, @p2, _, _, @p2, _] -> {@p2, [1, 4, 7]}
      [_, _, @p1, _, _, @p1, _, _, @p1] -> {@p1, [2, 5, 8]}
      [_, _, @p2, _, _, @p2, _, _, @p2] -> {@p2, [2, 5, 8]}
      # diagonals
      [@p1, _, _, _, @p1, _, _, _, @p1] -> {@p1, [0, 4, 9]}
      [_, _, @p2, _, @p2, _, @p2, _, _] -> {@p2, [2, 4, 6]}
      _ -> {nil, []}
    end
  end

  defp is_drawn(board) do
    Enum.count(board, &(&1 != @empty)) == length(board)
  end

  defp expand_win_state(win_state) do
    Enum.map(0..8, &(&1 in win_state))
  end
end
