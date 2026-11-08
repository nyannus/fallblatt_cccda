defmodule FallblattUIWeb.DisplayLive do
  use FallblattUIWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Fallblatt")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main>
      <h1>Fallblatt</h1>
    </main>
    """
  end
end
