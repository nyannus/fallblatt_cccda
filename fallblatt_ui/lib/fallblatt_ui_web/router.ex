defmodule FallblattUIWeb.Router do
  use FallblattUIWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FallblattUIWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", FallblattUIWeb do
    pipe_through :browser

    live "/", DisplayLive
  end
end
