# Finance Report Chart Strategy Refactor — Design

Date: 2026-08-10
Status: Approved design

## Goal

Refactor the finance report chart (`Reports::ViewFinanceReport`) so that the `EchartReportBuilder` no longer knows about week/month/year. Support three display modes with complete time series, zero-filling missing periods via PostgreSQL `generate_series`.

The module namespace stays `Reports::ViewFinanceReport`. All existing logic is replaced by the strategy-pattern design below.

## 1. Display modes

| mode | bucket | series |
|------|--------|--------|
| `week`  | day   | 7 days (Mon–Sun) |
| `month` | day   | all days in selected month (28–31) |
| `year`  | month | 12 months (Jan–Dec) |

Chart data must always contain the complete time series; periods without data have value `0`.

## 2. Request

```ruby
{
  display_mode: :week | :month | :year,   # default :week
  date: Date
}
```

## 3. Data source

Table `daily_finance_reports`:

```ruby
date        :date
value_type  :string
value       :decimal
```

Valid `value_type`s: `pos_revenue`, `eatclub_revenue`, `labour_cost`. Unique constraint on `(date, value_type)`. (Unchanged from the existing model/migration.)

## 4. File layout

```
app/modules/reports/view_finance_report/chart/
├── display_strategy.rb            # base class, defines the interface
├── week_strategy.rb
├── month_strategy.rb
├── year_strategy.rb
├── strategy_factory.rb            # .for(mode, date) -> strategy
├── finance_report_chart_query.rb  # generate_series + LEFT JOIN + DATE_TRUNC
└── echart_builder.rb              # rows + strategy -> ECharts JSON
```

Namespaces are `Reports::ViewFinanceReport::Chart::*` (module itself stays `Reports::ViewFinanceReport`).

Deleted:
- `app/modules/reports/view_finance_report/queries/finance_reports_query.rb` (+ empty `queries/` dir)
- `app/modules/reports/view_finance_report/services/echart_report_builder.rb` (+ empty `services/` dir)

## 5. DisplayStrategy interface

Base class `DisplayStrategy`, subclasses `WeekStrategy`, `MonthStrategy`, `YearStrategy`. Constructor takes `date` (Date). Each strategy implements:

- `display_range` → `Range` of Dates used as `generate_series` bounds
- `aggregation` → `:day` or `:month` (bucket unit for `DATE_TRUNC` and the `generate_series` step)
- `periods` → `Array<Date>` covering the range (Ruby-side truth for the series)
- `label_format(date)` → `String` xAxis label

| | WeekStrategy | MonthStrategy | YearStrategy |
|---|---|---|---|
| `display_range` | `date.beginning_of_week..date.end_of_week` | 1st..last day of month | `date.beginning_of_year..date.end_of_year` |
| `aggregation` | `:day` | `:day` | `:month` |
| `periods` | 7 days | days in month (28–31) | 12 month starts (Jan 1..Dec 1) |
| `label_format` | `strftime("%a %m-%d")` → "Mon 08-10" | `strftime("%b %d")` → "Aug 01" | `strftime("%b")` → "Jan" |

Strategies know nothing about SQL, `generate_series`, or the database.

## 6. FinanceReportChartQuery

`FinanceReportChartQuery.call(strategy)` — the only component that knows `generate_series` and SQL. Builds a fully parameterized raw query via `ActiveRecord::Base.connection.exec_query`:

```sql
SELECT series.day AS period,
       COALESCE(pos_revenue, 0) AS pos_revenue,
       COALESCE(eatclub_revenue, 0) AS eatclub_revenue,
       COALESCE(labour_cost, 0)  AS labour_cost
FROM generate_series(:start_date, :end_date, interval :step) AS series(day)
LEFT JOIN (
  SELECT DATE_TRUNC('day', date) AS bucket,
         SUM(value) FILTER (WHERE value_type = 'pos_revenue')    AS pos_revenue,
         SUM(value) FILTER (WHERE value_type = 'eatclub_revenue') AS eatclub_revenue,
         SUM(value) FILTER (WHERE value_type = 'labour_cost')    AS labour_cost
  FROM daily_finance_reports
  WHERE date BETWEEN :start_date AND :end_date
  GROUP BY DATE_TRUNC('day', date)
) agg ON agg.bucket = series.day
ORDER BY series.day
```

- `:start_date` / `:end_date` from `strategy.display_range`
- `:step` = `'1 day'` or `'1 month'` from `strategy.aggregation`
- `:month` bucket joins on `DATE_TRUNC('month', date) = series.day`

Returns an array of hashes in period order:

```ruby
[{ period: Date, pos_revenue: BigDecimal, eatclub_revenue: BigDecimal, labour_cost: BigDecimal }, ...]
```

Every period in the range is present; missing ones come back as 0 via LEFT JOIN + COALESCE. Raw query rows are normalized to `Date` / `BigDecimal` types.

## 7. EchartBuilder

`EchartBuilder.new(chart_data, strategy).call` — pure transformation, no DB/SQL knowledge. Input: query output rows + strategy. Output:

```ruby
{
  xAxis: { type: "category", data: labels },        # labels = rows.map { |r| strategy.label_format(r[:period]) }
  yAxis: { type: "value" },
  series: [
    { name: "POS Revenue",     type: "bar", stack: "Revenue", data: pos_revenue_values },
    { name: "EatClub Revenue", type: "bar", stack: "Revenue", data: eatclub_revenue_values },
    { name: "Labour Cost",     type: "bar", data: labour_cost_values }
  ]
}
```

Values are ordered to match the row order from the query.

## 8. StrategyFactory

`StrategyFactory.for(mode, date)` maps `week` / `month` / `year` (string or symbol) to the strategy class. Unknown mode raises `ArgumentError`.

## 9. Controller

`Api::V1::Reports::FinanceReportsController#index` honors both params, replacing the hardcoded `1.weeks.ago`:

```ruby
display_mode = params[:display_mode].presence || :week
target_date  = parse_date_param(params[:current_date])
strategy     = StrategyFactory.for(display_mode, target_date)
chart_data   = FinanceReportChartQuery.call(strategy)
render json: EchartBuilder.new(chart_data, strategy).call
```

`parse_date_param` stays as-is (blank → `Date.current`, `ArgumentError` → `Date.current`).

## 10. Error handling

- Unknown `display_mode` → `StrategyFactory.for` raises `ArgumentError`; controller rescues and renders `400` with an error message.
- Blank / invalid `current_date` → falls back to `Date.current` (existing helper behavior).

## 11. Flow

```
Controller
   |
   v
StrategyFactory.for(mode, date)
   |
   v
FinanceReportChartQuery.call(strategy)   # generate_series, aggregation, zero-fill
   |
   v
EchartBuilder.new(chart_data, strategy)
   |
   v
JSON response
```

## 12. Acceptance criteria

### Week
Given: no report exists on Wednesday. When: `display_mode=week`. Then: chart contains 7 points; Wednesday value = 0.

### Month
Given: August has reports only on Aug 1 and Aug 15. When: `display_mode=month`. Then: chart contains 31 points; Aug 01 value > 0, Aug 02 value = 0, ..., Aug 15 value > 0.

### Year
Given: reports exist only in Jan, Mar, Dec. When: `display_mode=year`. Then: chart contains 12 points; Feb and Apr–Nov values = 0.

## 13. Scope

This change excludes tests (added in a later pass). No schema or API route changes.