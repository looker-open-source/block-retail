view: stock_forecasting_explore_base {
  view_label: "Stock Forecasting 🏭"
  derived_table: {
    explore_source: transactions {
      column: transaction_week {}
      column: transaction_week_of_year {}
      column: product_name { field: products.name }
      column: product_image { field: products.product_image }
      column: category { field: products.category }
      column: brand { field: products.brand }
      column: store_id { field: stores.id }
      column: store_name { field: stores.name }
      column: number_of_customers {}
      column: number_of_transactions {}
      column: number_of_customer_transactions {}
      column: gross_margin { field: transactions__line_items.total_gross_margin }
      column: quantity { field: transactions__line_items.total_quantity }
      column: sales { field: transactions__line_items.total_sales }
      bind_filters: {
        from_field: stock_forecasting_explore_base.transaction_week_filter
        to_field: transactions.date_comparison_filter
      }
    }
  }
  filter: transaction_week_filter { type: date}
  dimension_group: transaction {
    type: time
    timeframes: [week,month,year]
    sql: TIMESTAMP(CAST(${TABLE}.transaction_week AS DATE)) ;;
  }
  dimension: transaction_week_of_year {
    group_label: "Transaction Date"
    type: number
    sql: IFNULL(${transaction_week_of_year_for_join},${stock_forecasting_prediction.transaction_week_of_year}) ;;
  }
  dimension: transaction_week_of_year_for_join {
    hidden: yes
    type: number
    sql:${TABLE}.transaction_week_of_year;;
  }
  dimension: product_name {
    sql: IFNULL(${product_name_for_join},${stock_forecasting_prediction.product_name}) ;;
    link: {
      label: "Drive attachments for {{rendered_value}}"
      icon_url: "https://i.imgur.com/W4tVGrj.png"
      url: "/dashboards/retail_block_model_v2::item_affinity_analysis?Focus%20Product={{value | encode_uri}}&Minimum%20Purchase%20Frequency="
    }
  }
  dimension: product_name_for_join {
    hidden: yes
    type: string
    sql:${TABLE}.product_name;;
  }
  dimension: product_image {
    view_label: "Product Detail 📦"
    html: <img src="@{IMAGE_SEARCH_URL}{{value | encode_uri }}" style="height: 50px; max-width: 150px;" /> ;;
  }
  dimension: category {
    view_label: "Product Detail 📦"
  }
  dimension: brand {
    view_label: "Product Detail 📦"
  }
  dimension: store_id {
    hidden: yes
    type: number
    sql: IFNULL(${store_id_for_join},${stock_forecasting_prediction.store_id}) ;;
  }
  dimension: store_id_for_join {
    hidden: yes
    type: number
    sql: ${TABLE}.store_id ;;
  }
  dimension: store_name {}
  dimension: number_of_customers {
    value_format: "#,##0"
    type: number
  }
  dimension: number_of_transactions {
    value_format: "#,##0"
    type: number
  }
  dimension: number_of_customer_transactions {
    value_format: "#,##0"
    type: number
  }
  dimension: gross_margin {
    label: "Transactions Gross Margin"
    value_format: "$#,##0"
    type: number
  }
  dimension: quantity {
    label: "Transactions Quantity"
    value_format: "#,##0"
    type: number
  }
  dimension: sales {
    label: "Transactions Sales"
    value_format: "$#,##0"
    type: number
  }

  ##### DERIVED DIMENSIONS #####

  set: drill_detail {
    fields: [transaction_week, store_id, product_name, total_quantity]
  }

  ##### MEASURES #####

  measure: total_number_of_transactions {
    type: sum
    sql: ${number_of_transactions} ;;
    value_format_name: decimal_0
    drill_fields: [drill_detail*]
  }

  measure: total_number_of_customer_transactions {
    hidden: yes
    type: sum
    sql: ${number_of_customer_transactions} ;;
    value_format_name: decimal_0
    drill_fields: [drill_detail*]
  }

  measure: total_number_of_customers {
    type: sum
    sql: ${number_of_customers} ;;
    value_format_name: decimal_0
    drill_fields: [drill_detail*]
  }

  measure: percent_customer_transactions {
    type: number
    sql: ${number_of_customer_transactions}/NULLIF(${number_of_transactions},0) ;;
    value_format_name: percent_1
    drill_fields: [drill_detail*]
  }

  measure: total_sales {
    type: sum
    sql: ${sales} ;;
    value_format_name: currency_0
    drill_fields: [drill_detail*]
  }

  measure: total_gross_margin {
    type: sum
    sql: ${gross_margin} ;;
    value_format_name: currency_0
    drill_fields: [drill_detail*]
  }

  measure: total_quantity {
    label: "Total Stock"
    type: sum
    sql: ${quantity} ;;
    value_format_name: decimal_0
    drill_fields: [drill_detail*]
  }

  measure: average_basket_size {
    type: number
    sql: ${total_sales}/NULLIF(${total_number_of_transactions},0) ;;
    value_format_name: currency
    drill_fields: [drill_detail*]
  }

  measure: average_item_price {
    type: number
    sql: ${total_sales}/NULLIF(${total_quantity},0) ;;
    value_format_name: currency
    drill_fields: [transactions.drill_detail*]
  }

  measure: stock_difference {
    type: number
    sql: ${stock_forecasting_prediction.forecasted_quantity}-${total_quantity} ;;
    value_format_name: decimal_0
  }

  measure: stock_difference_value {
    type: number
    sql: ${stock_difference}*${average_item_price} ;;
    value_format_name: currency
  }
}

###########################################################################################
###################################  BEGIN BQML MODEL  ####################################
###########################################################################################

view: stock_forecasting_input_base {
  derived_table: {
    explore_source: transactions {
      column: transaction_week_of_year {}
      column: transaction_timestamp_date {field: transactions.transaction_date}
      derived_column: transaction_date {sql: CAST(transaction_timestamp_date AS DATE) ;;}
      column: store_id { }
      column: product_name { field:products.name }
      column: product_category {field:products.category}
      column: store_tier_id { field: store_tiering.tier_id }
      column: average_basket_size { field: transactions__line_items.average_basket_size }
      column: average_item_price { field: transactions__line_items.average_item_price }
      column: number_of_customers {}
      column: number_of_transactions {}
      column: percent_customer_transactions {}
      column: total_gross_margin { field: transactions__line_items.total_gross_margin }
      column: total_quantity { field: transactions__line_items.total_quantity }
      column: total_sales { field: transactions__line_items.total_sales }
      column: average_daily_precipitation { field: store_weather.average_daily_precipitation }
      column: average_max_temperature { field: store_weather.average_max_temperature }
      column: average_min_temperature { field: store_weather.average_min_temperature }
      filters: {
        field: transactions.date_comparison_filter
        value: "2 years ago for 2 years"
      }
    }
  }
}

view: stock_forecasting_input {
  derived_table: {
    sql: SELECT distinct
          transaction_week_of_year
          ,store_id
          ,product_name
          ,product_category
          ,store_tier_id
          ,SUM(CASE WHEN transaction_date >= DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_quantity END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS total_quantity
          -- Product-Store-Week prior year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_basket_size END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS average_basket_size_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_item_price END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS average_item_price_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN number_of_customers END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS number_of_customers_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN number_of_transactions END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS number_of_transactions_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN percent_customer_transactions END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS percent_customer_transactions_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_gross_margin END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS total_gross_margin_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_quantity END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS total_quantity_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_sales END) OVER(PARTITION BY transaction_week_of_year,store_id,product_name) AS total_sales_prior_year
          -- Category-Week prior year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_basket_size END) OVER(PARTITION BY transaction_week_of_year,product_category) AS average_basket_size_category_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_item_price END) OVER(PARTITION BY transaction_week_of_year,product_category) AS average_item_price_category_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN number_of_customers END) OVER(PARTITION BY transaction_week_of_year,product_category) AS number_of_customers_category_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN number_of_transactions END) OVER(PARTITION BY transaction_week_of_year,product_category) AS number_of_transactions_category_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN percent_customer_transactions END) OVER(PARTITION BY transaction_week_of_year,product_category) AS percent_customer_transactions_category_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_gross_margin END) OVER(PARTITION BY transaction_week_of_year,product_category) AS total_gross_margin_category_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_quantity END) OVER(PARTITION BY transaction_week_of_year,product_category) AS total_quantity_category_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_sales END) OVER(PARTITION BY transaction_week_of_year,product_category) AS total_sales_category_prior_year
          -- Store-Week prior year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_basket_size END) OVER(PARTITION BY transaction_week_of_year,store_id) AS average_basket_size_store_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_item_price END) OVER(PARTITION BY transaction_week_of_year,store_id) AS average_item_price_store_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN number_of_customers END) OVER(PARTITION BY transaction_week_of_year,store_id) AS number_of_customers_store_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN number_of_transactions END) OVER(PARTITION BY transaction_week_of_year,store_id) AS number_of_transactions_store_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN percent_customer_transactions END) OVER(PARTITION BY transaction_week_of_year,store_id) AS percent_customer_transactions_store_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_gross_margin END) OVER(PARTITION BY transaction_week_of_year,store_id) AS total_gross_margin_store_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_quantity END) OVER(PARTITION BY transaction_week_of_year,store_id) AS total_quantity_store_prior_year
          ,SUM(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN total_sales END) OVER(PARTITION BY transaction_week_of_year,store_id) AS total_sales_store_prior_year
          ,AVG(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_max_temperature END) OVER(PARTITION BY transaction_week_of_year,store_id) AS average_max_temperature_store_prior_year
          ,AVG(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_min_temperature END) OVER(PARTITION BY transaction_week_of_year,store_id) AS average_min_temperature_store_prior_year
          ,AVG(CASE WHEN transaction_date < DATE_ADD(CURRENT_DATE(),INTERVAL -1 YEAR) THEN average_daily_precipitation END) OVER(PARTITION BY transaction_week_of_year,store_id) AS average_daily_precipitation_store_prior_year
        FROM ${stock_forecasting_input_base.SQL_TABLE_NAME} ;;
  }
}

view: stock_forecasting_regression {
  derived_table: {
    datagroup_trigger: weekly
    sql_create:
      CREATE OR REPLACE MODEL ${SQL_TABLE_NAME}
      OPTIONS(model_type='linear_reg'
        , labels=['total_quantity']
        , min_rel_progress = 0.05
        , max_iteration = 50
        ) AS
      SELECT
         * EXCEPT(transaction_week_of_year, store_id, product_name)
      FROM ${stock_forecasting_input.SQL_TABLE_NAME}
      WHERE total_quantity is not null ;;
  }
}

view: stock_forecasting_prediction {
  derived_table: {
    sql: SELECT transaction_week_of_year,store_id,product_name
        ,CONCAT(CAST(transaction_week_of_year AS STRING),'_',CAST(store_id AS STRING),product_name) AS pk
        ,product_category
        ,predicted_total_quantity
      FROM ml.PREDICT(
      MODEL ${stock_forecasting_regression.SQL_TABLE_NAME},
      (SELECT * FROM ${stock_forecasting_input.SQL_TABLE_NAME}));;
    datagroup_trigger: weekly
  }

  dimension: pk {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}.pk ;;
  }

  dimension: transaction_week_of_year {
    hidden: yes
    type: number
    sql: ${TABLE}.transaction_week_of_year ;;
  }

  dimension: store_id {
    hidden: yes
    type: number
    sql: ${TABLE}.store_id ;;
  }

  dimension: product_name {
    hidden: yes
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: product_category {
    hidden: yes
    type: string
    sql: ${TABLE}.product_category ;;
  }

  dimension: predicted_total_quantity {
    hidden: yes
    type: number
    sql: ${TABLE}.predicted_total_quantity ;;
  }

  dimension: predicted_total_quantity_rounded {
    hidden: yes
    type: number
    sql: ROUND(${predicted_total_quantity},0) ;;
  }

  measure: forecasted_quantity {
    view_label: "Stock Forecasting 🏭"
    label: "Forecasted Stock 📈"
    type: sum
    sql: ${predicted_total_quantity_rounded} ;;
    value_format_name: decimal_0
  }
}
