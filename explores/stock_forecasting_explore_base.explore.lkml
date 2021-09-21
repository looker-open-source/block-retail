include: "/views/*.view"

explore: stock_forecasting_explore_base {
  label: "(2) Stock Forecasting 🏭"

  always_filter: {
    filters: {
      field: transaction_week_filter
      value: "last 12 weeks"
    }
  }

  join: stock_forecasting_prediction {
    relationship: one_to_one
    type: full_outer
    sql_on: ${stock_forecasting_explore_base.transaction_week_of_year_for_join} = ${stock_forecasting_prediction.transaction_week_of_year}
          AND ${stock_forecasting_explore_base.store_id_for_join} = ${stock_forecasting_prediction.store_id}
          AND ${stock_forecasting_explore_base.product_name_for_join} = ${stock_forecasting_prediction.product_name};;
  }
}
