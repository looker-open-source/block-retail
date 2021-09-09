connection: "@{CONNECTION_NAME}"
label: "Retail Application"

# View Includes
include: "/views/**/*.view" # include all the views
# Dashboard Includes
include: "/dashboards/*.dashboard.lookml" # include all the dashboards

# Include from Config project:
include: "//@{CONFIG_PROJECT_NAME}/views/*.view"
include: "//@{CONFIG_PROJECT_NAME}/additional_views/*.view"
include: "//@{CONFIG_PROJECT_NAME}/models/retail_block_model_config.explores.lkml"

# Value formats:
named_value_format: currency_k {
  value_format: "\"@{MAIN_CURRENCY_SYMBOL}\"#,##0.0,\" K\""
}
named_value_format: currency {
  value_format: "\"@{MAIN_CURRENCY_SYMBOL}\"#,##0.00"
}
named_value_format: currency_0 {
  value_format: "\"@{MAIN_CURRENCY_SYMBOL}\"#,##0"
}
named_value_format: unit_k {
  value_format: "#,##0.0,\" K\""
}

# Explores:
explore: transactions {
  extends: [transactions_config]
}

explore: transactions_core {
  extension: required
  label: "(1) Transaction Detail 🏷"
  always_filter: {
    filters: {
      field: date_comparison_filter
      value: "last 30 days"
    }
  }

  join: transactions__line_items {
    relationship: one_to_many
    sql: LEFT JOIN UNNEST(${transactions.line_items}) transactions__line_items ;;
  }

  join: customers {
    relationship: many_to_one
    sql_on: ${transactions.customer_id} = ${customers.id} ;;
  }

  join: customer_facts {
    relationship: many_to_one
    view_label: "Customers 👥"
    sql_on: ${transactions.customer_id} = ${customer_facts.customer_id} ;;
  }

  join: customer_favorite_store {
    relationship: many_to_one
    sql_on: ${transactions.customer_id} = ${customer_favorite_store.customer_id} ;;
  }

  join: customer_favorite_store_details {
    view_label: "Customers 👥"
    relationship: many_to_one
    fields: [customer_favorite_store_details.name,customer_favorite_store_details.location]
    sql_on: ${customer_facts.customer_favorite_store_id} = ${customer_favorite_store_details.id} ;;
  }

  join: products {
    relationship: many_to_one
    sql_on: ${products.id} = ${transactions__line_items.product_id} ;;
  }

  join: stores {
    type: left_outer
    sql_on: ${stores.id} = ${transactions.store_id} ;;
    relationship: many_to_one
  }

  join: store_tiering {
    type: left_outer
    sql_on: ${transactions.store_id} = ${store_tiering.store_id} ;;
    relationship: many_to_one
  }

  join: channels {
    type: left_outer
    view_label: "Transactions"
    sql_on: ${channels.id} = ${transactions.channel_id} ;;
    relationship: many_to_one
  }

  join: customer_transaction_sequence {
    relationship: many_to_one
    sql_on: ${transactions.customer_id} = ${customer_transaction_sequence.customer_id}
      AND ${transactions.transaction_raw} = ${customer_transaction_sequence.transaction_raw} ;;
  }

  join: store_weather {
    relationship: many_to_one
    sql_on: ${transactions.transaction_date} = ${store_weather.weather_date}
      AND ${transactions.store_id} = ${store_weather.store_id};;
  }

  join: customer_clustering_prediction {
    view_label: "Customers 👥"
    relationship: many_to_one
    sql_on: ${transactions.customer_id} = ${customer_clustering_prediction.customer_id} ;;
  }

  sql_always_where: {% if transactions.date_comparison_filter._is_filtered %}
  {% if transactions.comparison_type._parameter_value == 'current' %}
  {% condition transactions.date_comparison_filter %} ${transaction_raw} {% endcondition %}
  {% elsif transactions.comparison_type._parameter_value == 'year' %}
  {% condition transactions.date_comparison_filter %} ${transaction_raw} {% endcondition %} OR (${transaction_raw} >= TIMESTAMP(DATE_ADD(CAST({% date_start transactions.date_comparison_filter %} AS DATE),INTERVAL -1 YEAR)) AND ${transaction_raw} <= TIMESTAMP(DATE_ADD(CAST({% date_end transactions.date_comparison_filter %} AS DATE),INTERVAL -364 DAY)))
  {% elsif transactions.comparison_type._parameter_value == 'week' %}
  {% condition transactions.date_comparison_filter %} ${transaction_raw} {% endcondition %} OR (${transaction_raw} >= TIMESTAMP(DATE_ADD(CAST({% date_start transactions.date_comparison_filter %} AS DATE),INTERVAL -1 WEEK)) AND ${transaction_raw} <= TIMESTAMP(DATE_ADD(CAST({% date_end transactions.date_comparison_filter %} AS DATE),INTERVAL -6 DAY)))
  {% else %}
  1=1
  {% endif %}
  {% else %}
  1=1
  {% endif %};;
}

explore: stock_forecasting_explore_base {
  extends: [stock_forecasting_explore_base_config]
}

explore: stock_forecasting_explore_base_core {
  extension: required
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

explore: order_purchase_affinity {
  extends: [order_purchase_affinity_config]
}

explore: order_purchase_affinity_core {
  extension: required
  label: "(3) Item Affinity 🔗"
  view_label: "Item Affinity"

  always_filter: {
    filters: {
      field: affinity_timeframe
      value: "last 90 days"
    }
    filters: {
      field: order_items_base.product_level
      value: "product"
    }
  }

  join: order_items_base {}

  join: total_orders {
    type: cross
    relationship: many_to_one
  }
}

explore: customer_clustering_prediction {
  extends: [customer_clustering_prediction_config]
}

explore: customer_clustering_prediction_core {
  extension: required
  hidden: yes
  label: "(4) Customer Segments 👤"
  fields: [customer_clustering_prediction.customer_segment_basic_dim]
}

# Datagroups:

datagroup: daily {
  sql_trigger: SELECT CURRENT_DATE() ;;
  max_cache_age: "24 hours"
}

datagroup: weekly {
  sql_trigger: SELECT EXTRACT(WEEK FROM CURRENT_DATE()) ;;
}

datagroup: monthly {
  sql_trigger: SELECT EXTRACT(MONTH FROM CURRENT_DATE()) ;;
}

datagroup: forever {
  sql_trigger: SELECT 1 ;;
}
