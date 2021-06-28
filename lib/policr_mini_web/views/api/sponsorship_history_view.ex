defmodule PolicrMiniWeb.API.SponsorshipHistoryView do
  @moduledoc """
  渲染前台赞助历史数据。
  """

  use PolicrMiniWeb, :view

  @spec render(String.t(), map()) :: map()
  def render("sponsorship_history.json", %{sponsorship_history: sponsorship_history}) do
    sponsor =
      render_one(sponsorship_history.sponsor, PolicrMiniWeb.API.SponsorView, "sponsor.json")

    sponsorship_history
    |> Map.drop([:__meta__, :sponsor])
    |> Map.from_struct()
    |> Map.put(:sponsor, sponsor)
  end

  def render("added.json", %{sponsorship_history: sponsorship_history, uuid: uuid}) do
    sponsorship_history = render_one(sponsorship_history, __MODULE__, "sponsorship_history.json")

    %{sponsorship_history: sponsorship_history, uuid: uuid}
  end

  def render("index.json", %{
        sponsorship_histories: sponsorship_histories,
        hints: hints
      }) do
    %{
      sponsorship_histories:
        render_many(sponsorship_histories, __MODULE__, "sponsorship_history.json"),
      hints: hints
    }
  end
end
