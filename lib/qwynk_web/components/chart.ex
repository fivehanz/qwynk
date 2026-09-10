defmodule QwynkWeb.Chart do
  @moduledoc """
  Server-rendered SVG area chart.

  ponytail: no D3. That is ~250KB and a JS build step to plot 30 points that
  LiveView already re-renders on every update, and inline SVG works with JS
  disabled. Add D3 when the chart needs brushing, zoom or interactive tooltips
  — and update PRD 2 and BRAND.md's stack list when you do.
  """
  use Phoenix.Component

  attr :rows, :list, required: true, doc: "[%{date:, clicks:, uniques:}]"
  attr :height, :integer, default: 160
  attr :class, :string, default: ""

  def area_chart(assigns) do
    rows = assigns.rows
    max = rows |> Enum.map(& &1.clicks) |> Enum.max(fn -> 0 end) |> max(1)
    width = 600
    step = if length(rows) > 1, do: width / (length(rows) - 1), else: width

    point = fn value, index ->
      x = Float.round(index * step, 2)
      y = Float.round(assigns.height - value / max * (assigns.height - 8) - 4, 2)
      {x, y}
    end

    to_points = fn key ->
      rows
      |> Enum.with_index()
      |> Enum.map_join(" ", fn {row, i} ->
        {x, y} = point.(Map.fetch!(row, key), i)
        "#{x},#{y}"
      end)
    end

    assigns =
      assign(assigns,
        clicks_points: to_points.(:clicks),
        uniques_points: to_points.(:uniques),
        width: width,
        max: max,
        empty?: Enum.all?(rows, &(&1.clicks == 0))
      )

    ~H"""
    <figure class={["w-full", @class]}>
      <svg
        viewBox={"0 0 #{@width} #{@height}"}
        preserveAspectRatio="none"
        class="h-40 w-full"
        role="img"
        aria-label={"Clicks over the last #{length(@rows)} days, peak #{@max}"}
      >
        <polyline
          points={@clicks_points}
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          class="text-primary"
          vector-effect="non-scaling-stroke"
        />
        <polyline
          points={@uniques_points}
          fill="none"
          stroke="currentColor"
          stroke-width="1.5"
          stroke-dasharray="4 3"
          class="text-secondary opacity-70"
          vector-effect="non-scaling-stroke"
        />
      </svg>
      <figcaption class="mt-2 flex justify-between font-mono text-xs opacity-60">
        <span :if={@empty?}>No traffic yet</span>
        <span :if={!@empty?}>
          <span class="text-primary">━</span>
          clicks <span class="ml-3 text-secondary">╌</span>
          uniques
        </span>
        <span>peak {@max}/day</span>
      </figcaption>
    </figure>
    """
  end
end
