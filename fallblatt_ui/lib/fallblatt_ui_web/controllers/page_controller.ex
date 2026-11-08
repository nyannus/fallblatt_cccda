defmodule FallblattUIWeb.PageController do
  use FallblattUIWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
