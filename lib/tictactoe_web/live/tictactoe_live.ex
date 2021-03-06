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
      game_state: @gamestate_ing
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
    # IO.inspect(cell_id)
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
    socket
    |> assign(game_state: cal_game_state(board))
  end

  defp cal_game_state(board) do
    cond do
      is_drawn(board) ->
        IO.puts("Draw!")
        @gamestate_draw

      has_won(board, @p1) ->
        IO.puts("P1 wins!")
        @gamestate_p1

      has_won(board, @p2) ->
        IO.puts("P2 wins!")
        @gamestate_p2

      true ->
        @gamestate_ing
    end
  end

  defp has_won(board, p) do
    case board do
      # horizontals
      [^p, ^p, ^p | _] -> true
      [_, _, _, ^p, ^p, ^p | _] -> true
      [_, _, _, _, _, _, _, _, ^p, ^p, ^p] -> true
      # verticals
      [^p, _, _, ^p, _, _, ^p, _, _] -> true
      [_, ^p, _, _, ^p, _, _, ^p, _] -> true
      [_, _, ^p, _, _, ^p, _, _, ^p] -> true
      # diagonals
      [^p, _, _, _, ^p, _, _, _, ^p] -> true
      [_, _, ^p, _, ^p, _, ^p, _, _] -> true
      # draw
      _ -> false
    end
  end

  defp is_drawn(board) do
    Enum.count(board, &(&1 != @empty)) == length(board)
  end
end
