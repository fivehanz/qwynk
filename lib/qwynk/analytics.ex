defmodule Qwynk.Analytics do
  use Ash.Domain, otp_app: :qwynk

  resources do
    resource Qwynk.Analytics.Hit do
      define :list_hits, action: :read
    end

    resource Qwynk.Analytics.DailySalt do
      define :list_salts, action: :read
      define :purge_salt, action: :purge
    end
  end

  @doc """
  Daily clicks and unique visitors for a link, zero-filled over `days`.

  ponytail: raw SQL. Ash aggregates cannot express count(distinct ...) grouped
  by day without a custom fragment, and generate_series does the zero-filling
  in the database so there is no gap-filling code here at all.
  """
  def stats(link_id, days \\ 30) do
    since = Date.add(Date.utc_today(), -(days - 1))

    %{rows: rows} =
      Qwynk.Repo.query!(
        """
        select d::date,
               count(h.id),
               count(distinct h.visitor_hash)
          from generate_series($2::date, current_date, '1 day') d
          left join hits h
            on h.link_id = $1 and h.timestamp::date = d::date
         group by d
         order by d
        """,
        [Ecto.UUID.dump!(link_id), since]
      )

    Enum.map(rows, fn [date, clicks, uniques] ->
      %{date: date, clicks: clicks, uniques: uniques}
    end)
  end

  @doc "Totals across every link owned by `user`, over `days`."
  def totals(user_id, days \\ 30) do
    since = Date.add(Date.utc_today(), -(days - 1))

    %{rows: [[links, clicks, uniques]]} =
      Qwynk.Repo.query!(
        """
        select (select count(*) from links where owner_id = $1),
               count(h.id),
               count(distinct h.visitor_hash)
          from hits h
          join links l on l.id = h.link_id
         where l.owner_id = $1 and h.timestamp::date >= $2::date
        """,
        [Ecto.UUID.dump!(user_id), since]
      )

    %{links: links, clicks: clicks, uniques: uniques}
  end

  @doc "Deletes salts past the retention window."
  def purge_salts do
    Qwynk.Analytics.DailySalt
    |> Ash.bulk_destroy!(:purge, %{}, authorize?: false, strategy: [:atomic, :stream])
    |> then(fn _ -> :ok end)
  end
end
