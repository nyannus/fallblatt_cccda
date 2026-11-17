defmodule FallblattUIWeb.DisplayLive do
  use FallblattUIWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Fallblatt")
     |> assign(fbms: String.split("ELLO :3      ", "") |> Enum.slice(1..-2//1))
     |> assign(transactions: [List.duplicate(%{

     }, 8)])}
  end

  def fbm(assigns) do
    ~H"""
      <.column class="mx-1 grow-1">
        <.card>
          <.card_body class="flex bg-black aspect-4/5 justify-center items-center outline-red-500">
            <span class="text-white !text-6xl text-center mx-auto fallblatt">
              {@fbm}
            </span>
          </.card_body>
          <div class="flex flex-row !border-b-4 !border-red-500">
            <.button kind="ghost" class="flex-1">
              <.icon_indicator kind="unknown"/>
            </.button>
            <.button kind="ghost" class="flex-1">
              <CoreComponents.icon name="chevron--down" slot="icon"/>
            </.button>
          </div>
        </.card>
      </.column>
    """
  end

  def log(assigns) do
    ~H"""
      <.card_header class="mb-4">Transaction Log</.card_header>
      <.table locale="en">
        <.table_head>
          <.table_header_row>
            <.table_header_cell class="!ms-4 w-8"></.table_header_cell>
            <.table_header_cell>Timestamp</.table_header_cell>
            <.table_header_cell>Command</.table_header_cell>
            <.table_header_cell>Status</.table_header_cell>
            <.table_header_cell>RTT</.table_header_cell>
            <.table_header_cell>Response</.table_header_cell>
          </.table_header_row>
        </.table_head>
        <.table_body :for={_ <- 1..10}>
          <.table_row>
            <.table_cell class="!ms-4"><CoreComponents.icon name="arrow--right"/></.table_cell>
            <.table_cell>{DateTime.now!("Etc/UTC") |> DateTime.to_time()}</.table_cell>
            <.table_cell>del #1</.table_cell>
            <.table_cell><.icon_indicator kind="unknown"/></.table_cell>
            <.table_cell>15 ms</.table_cell>
            <.table_cell>&lt;&lt;3 bytes&gt;&gt;</.table_cell>
          </.table_row>
        </.table_body>
      </.table>
    """
  end

  def actions(assigns) do
    ~H"""
      <.card_header class="mb-4">Quick actions</.card_header>

      <div class="flex gap-4">
        <.dropdown title_text="Color" helper_text="Yellow digits only" value="white" class="flex-2">
          <.dropdown_item value="white">White</.dropdown_item>
          <.dropdown_item value="yellow">Yellow</.dropdown_item>
        </.dropdown>

        <.text_input class="flex-5" label="Text" helper_text="Use uppercase letters">
        </.text_input>

        <.button kind="primary" class="self-center flex-1 h-8">
          <CoreComponents.icon name="send"/>
        </.button>
      </div>
    """
  end

  def settings(assigns) do
    ~H"""
      <.card_header>Module settings</.card_header>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
      <.header>
        <.header_name> Krone9000 Fallblattanzeige @ CCCDA </.header_name>
      </.header>

      <.layer class="cds--content mt-12 h-screen flex-col">

        <div class="flex flex-row w-full overflow-x-scroll py-4 max-w-screen">
          <.fbm :for={fbm <- @fbms} fbm={fbm}/>
        </div>

        <div class="flex flex-grow flex-col lg:flex-row !mt-8 gap-4 items-stretch h-full">
          <div with-background class="flex-1 flex flex-col gap-4 p-4">
            <.layer with-background class="flex-1 p-4">
              <.actions {assigns}/>
            </.layer>
            <.layer with-background class="flex-1 p-4">
              <.settings {assigns}/>
            </.layer>
          </div>
          <.layer with-background class="flex-1 p-4">
            <.log {assigns}/>
          </.layer>
        </div>
      </.layer>
    """
  end
end
