defmodule PolicrMiniWeb.API.ThirdPartyController do
  @moduledoc """
  第三方实例的前台 API 控制器。
  """

  use PolicrMiniWeb, :controller

  alias PolicrMini.ThirdPartyBusiness

  action_fallback PolicrMiniWeb.API.FallbackController

  plug CORSPlug, origin: &__MODULE__.load_origins/0

  @project_start_date ~D[2020-06-01]

  def offical_bot do
    %PolicrMini.Schema.ThirdParty{
      name: "Policr Mini",
      bot_username: "policr_mini_bot",
      homepage: "https://mini.telestd.me",
      description: "由 Telestd 项目组维护、POLICR 社区运营",
      running_days: Date.diff(Date.utc_today(), @project_start_date),
      is_forked: false
    }
  end

  def index(conn, _params) do
    third_parties = ThirdPartyBusiness.find_list()

    {current_index, official_index, third_parties} =
      case get_req_header(conn, "referer") do
        [referer] ->
          r =
            third_parties
            |> Enum.with_index()
            |> Enum.find(fn {third_party, _} ->
              referer == PolicrMiniWeb.handle_url(third_party.homepage, has_end_slash: true)
            end)

          if r do
            current_index = elem(r, 1)

            third_parties = List.insert_at(third_parties, current_index + 1, offical_bot())

            {current_index, current_index + 1, third_parties}
          else
            # 没有找到此实例。
            if referer == PolicrMiniWeb.root_url(has_end_slash: true) do
              # 此实例为官方实例。
              {0, 0, [offical_bot()] ++ third_parties}
            else
              # 非官方实例。
              {-1, 0, [offical_bot()] ++ third_parties}
            end
          end

        [] ->
          # 无此实例。
          {-1, 0, [offical_bot()] ++ third_parties}
      end

    render(conn, "index.json", %{
      third_parties: third_parties,
      official_index: official_index,
      current_index: current_index
    })
  end

  # TODO: 使用专门的 Plug 缓存 `third_parties` 数据，以避免在 API 实现中出现重复查询。
  def load_origins do
    third_parties = ThirdPartyBusiness.find_list()

    Enum.map(third_parties, fn third_party -> third_party.homepage end)
  end
end