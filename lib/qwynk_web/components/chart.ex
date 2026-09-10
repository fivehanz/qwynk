defmodule QwynkWeb.Chart do
  @moduledoc """
  Server-rendered SVG instruments.

  ponytail: no D3. That is ~250KB and a JS build step to plot 30 points that
  LiveView already re-renders on every update, and inline SVG works with JS
  disabled. Hover readouts come from native `<title>` elements — zero script.
  Add D3 only when brushing or zoom is actually needed.
  """
  use Phoenix.Component

  # Wide aspect on purpose: the SVG scales uniformly to its container, so a
  # squarer viewBox renders an absurdly tall chart at full content width.
  @w 900
  @h 150
  @pad_l 34
  @pad_r 10
  @pad_b 18
  @pad_t 10

  attr :rows, :list, required: true, doc: "[%{date:, clicks:, uniques:}]"
  attr :class, :string, default: ""

  def area_chart(assigns) do
    rows = assigns.rows
    peak = rows |> Enum.map(& &1.clicks) |> Enum.max(fn -> 0 end)
    scale_max = nice_ceiling(peak)
    plot_w = @w - @pad_l - @pad_r
    plot_h = @h - @pad_b - @pad_t
    step = if length(rows) > 1, do: plot_w / (length(rows) - 1), else: plot_w

    x = fn i -> Float.round(@pad_l + i * step, 2) end
    y = fn v -> Float.round(@pad_t + plot_h - v / scale_max * plot_h, 2) end

    line = fn key ->
      rows
      |> Enum.with_index()
      |> Enum.map_join(" ", fn {r, i} -> "#{x.(i)},#{y.(Map.fetch!(r, key))}" end)
    end

    baseline = y.(0)

    area =
      "#{@pad_l},#{baseline} " <>
        line.(:clicks) <> " #{x.(length(rows) - 1)},#{baseline}"

    peak_index = Enum.find_index(rows, &(&1.clicks == peak))

    assigns =
      assign(assigns,
        w: @w,
        h: @h,
        plot_r: @w - @pad_r,
        pad_l: @pad_l,
        pad_t: @pad_t,
        clicks_line: line.(:clicks),
        uniques_line: line.(:uniques),
        area: area,
        baseline: baseline,
        gridlines: for(f <- [0.5, 1.0], do: %{y: y.(scale_max * f), label: round(scale_max * f)}),
        points: Enum.with_index(rows) |> Enum.map(fn {r, i} -> Map.put(r, :x, x.(i)) end),
        marker: peak > 0 && %{x: x.(peak_index), y: y.(peak), value: peak},
        empty?: peak == 0,
        first: List.first(rows),
        mid: Enum.at(rows, div(length(rows), 2)),
        last: List.last(rows),
        total: rows |> Enum.map(& &1.clicks) |> Enum.sum(),
        days: length(rows),
        plot_h: plot_h
      )

    ~H"""
    <figure class={@class}>
      <svg
        viewBox={"0 0 #{@w} #{@h}"}
        class="w-full"
        role="img"
        aria-label={"Daily clicks over #{@days} days: #{@total} total, peak #{if @marker, do: @marker.value, else: 0} in a day"}
      >
        <line
          :for={g <- @gridlines}
          x1={@pad_l}
          x2={@plot_r}
          y1={g.y}
          y2={g.y}
          class="stroke-base-300"
          stroke-width="1"
          stroke-dasharray="2 4"
        />
        <text
          :for={g <- @gridlines}
          x={@pad_l - 8}
          y={g.y + 3}
          text-anchor="end"
          class="fill-secondary font-mono text-[9px]"
        >
          {g.label}
        </text>

        <line
          x1={@pad_l}
          x2={@plot_r}
          y1={@baseline}
          y2={@baseline}
          class="stroke-base-300"
          stroke-width="1"
        />

        <%!-- Flat 8% fill, not a gradient: BRAND.md 3 rule 1. --%>
        <polygon :if={!@empty?} points={@area} class="fill-primary/[0.08]" />

        <polyline
          :if={!@empty?}
          points={@uniques_line}
          fill="none"
          stroke-width="1.25"
          stroke-dasharray="3 3"
          class="stroke-secondary"
          vector-effect="non-scaling-stroke"
        />
        <polyline
          :if={!@empty?}
          points={@clicks_line}
          fill="none"
          stroke-width="1.75"
          stroke-linejoin="round"
          class="stroke-primary"
          vector-effect="non-scaling-stroke"
        />

        <g :if={@marker}>
          <circle cx={@marker.x} cy={@marker.y} r="2.5" class="fill-primary" />
        </g>

        <%!-- Invisible hit targets carrying native tooltips. No JS. --%>
        <g>
          <rect
            :for={p <- @points}
            x={p.x - 8}
            y={@pad_t}
            width="16"
            height={@plot_h}
            fill="transparent"
            class="hover:fill-primary/5"
          >
            <title>
              {Calendar.strftime(p.date, "%b %-d")} · {p.clicks} clicks · {p.uniques} unique
            </title>
          </rect>
        </g>
      </svg>

      <div class="mt-2 flex items-baseline justify-between gap-4 font-mono text-[0.6875rem] text-secondary">
        <span>{Calendar.strftime(@first.date, "%b %-d")}</span>
        <span class="hidden sm:inline">{Calendar.strftime(@mid.date, "%b %-d")}</span>
        <span>{Calendar.strftime(@last.date, "%b %-d")}</span>
      </div>

      <figcaption class="mt-3 flex flex-wrap items-center gap-x-4 gap-y-1 text-[0.6875rem] text-secondary">
        <span :if={@empty?}>No traffic in this window.</span>
        <span :if={!@empty?} class="flex items-center gap-1.5">
          <span class="inline-block h-px w-3 bg-primary"></span> clicks
        </span>
        <span :if={!@empty?} class="flex items-center gap-1.5">
          <span class="inline-block h-px w-3 border-t border-dashed border-secondary"></span>
          unique visitors
        </span>
        <span :if={@marker} class="font-mono">peak {@marker.value}/day</span>
      </figcaption>
    </figure>
    """
  end

  attr :rows, :list, required: true
  attr :class, :string, default: ""

  @doc "Compact inline sparkline for the dashboard rail."
  def sparkline(assigns) do
    rows = assigns.rows
    max = rows |> Enum.map(& &1.clicks) |> Enum.max(fn -> 0 end) |> max(1)
    w = 160
    h = 28
    # Inset by half the stroke plus a little, so a peak at full height is not
    # sheared off by the viewBox edge.
    inset = 3
    step = if length(rows) > 1, do: w / (length(rows) - 1), else: w

    points =
      rows
      |> Enum.with_index()
      |> Enum.map_join(" ", fn {r, i} ->
        y = h - inset - r.clicks / max * (h - inset * 2)
        "#{Float.round(i * step, 2)},#{Float.round(y, 2)}"
      end)

    assigns = assign(assigns, points: points, w: w, h: h, flat?: max == 1)

    ~H"""
    <svg viewBox={"0 0 #{@w} #{@h}"} class={["h-7", @class]} aria-hidden="true">
      <polyline
        points={@points}
        fill="none"
        stroke-width="1.5"
        class={if @flat?, do: "stroke-base-300", else: "stroke-primary"}
        vector-effect="non-scaling-stroke"
      />
    </svg>
    """
  end

  # Round the axis up to something a human reads cleanly, so gridline labels are
  # never 7 or 13.
  defp nice_ceiling(0), do: 4
  defp nice_ceiling(n) when n <= 4, do: 4

  defp nice_ceiling(n) do
    magnitude = :math.pow(10, Float.floor(:math.log10(n))) |> trunc()
    Enum.find([1, 2, 5, 10], &(n <= &1 * magnitude)) |> Kernel.*(magnitude)
  end
end
