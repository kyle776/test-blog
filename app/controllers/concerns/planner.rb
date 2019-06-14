module Planner
  extend ActiveSupport::Concern

  # def horizontal_planner(past_weeks=1, seldate=Date.today, future_weeks=4, &block)
  #   # TODO: Implement horizontal planner
  #   # # Slice our dates in to weekly arrays
  #   # build_planner(past_weeks, seldate, future_weeks, &block).each_slice(7).to_a
  # end

  def vertical_planner(past_weeks=1, seldate=Date.today, future_weeks=4, &block)
    # Slice & Transpose our dates so we can output them in a table
    rows = build_planner(past_weeks, seldate, future_weeks, &block).each_slice(7).to_a.transpose
    # Determine the dates when weeks start
    weeks = rows.first
    # Determine the month and number of weeks displayed in the month
    months = rows.first.map{|x| x[0].strftime("%B")}.group_by{|x| x}.map {|k, v| [k,v.size]}
    weekdays = rows.each.map { |row| row.first[0].strftime("%a") }
    {headings:{months: months, weeks: weeks, weekdays: weekdays}, rows: rows}
  end

  private

  def build_planner(past_weeks=1, seldate=Time.zone.now, future_weeks=4, &block)
    # Determine the first date on our planner
    first_date = (seldate - (past_weeks * 7).days).monday
    # Determine the last date on our planner
    last_date = first_date + ((past_weeks + 1 + future_weeks) * 7).days - 1.day
    # Generate an array of dates to populate our planner
    dates = (first_date..last_date).to_a.map do |date|
      [date, today_results(date)]
      # block_given? ? [date, block.call(date)] : [date]
    end
  end

  def today_results(todays_date)
    Post.where(created_at: todays_date.beginning_of_day..todays_date.end_of_day)
  end
end
