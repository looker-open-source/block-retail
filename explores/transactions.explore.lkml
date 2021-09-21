include: "/views/*.view"

explore: transactions {
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
