include: "./base_dim_stores.view"

view: customer_store_sales {
  derived_table: {
    explore_source: transactions {
      column: customer_id {}
      column: store_id {}
      column: total_sales { field: transactions__line_items.total_sales }
      filters: {
        field: transactions.date_comparison_filter
        value: ""
      }
      filters: {
        field: transactions.is_customer
        value: "yes"
      }
    }
  }
}

view: customer_favorite_store {
  derived_table: {
    sql: SELECT distinct customer_id
      , FIRST_VALUE(store_id) OVER (PARTITION BY customer_id order by total_sales DESC) AS favorite_store_id
      FROM ${customer_store_sales.SQL_TABLE_NAME} ;;
  }
  dimension: customer_id {hidden:yes}
  dimension: favorite_store_id {hidden:yes}
}

view: customer_favorite_store_details {
  extends: [stores]

  dimension: location {group_label:"Customer Favorite Store"}
  dimension: name {group_label: "Customer Favorite Store"}
}

view: customer_facts {
  view_label: "Customers 👥"
  derived_table: {
    datagroup_trigger: weekly
    explore_source: transactions {
      column: customer_id {}
      column: customer_average_basket_size { field: transactions__line_items.average_basket_size }
      column: customer_lifetime_gross_margin { field: transactions__line_items.total_gross_margin }
      column: customer_lifetime_sales { field: transactions__line_items.total_sales }
      column: customer_lifetime_transactions { field: transactions.number_of_transactions }
      column: customer_lifetime_quantity { field: transactions__line_items.total_quantity }
      column: customer_first_purchase_date { field: transactions.first_transaction }
      column: customer_spend_trend_past_year { field: transactions__line_items.sales_trend_past_year }
      column: customer_favorite_store_id { field: customer_favorite_store.favorite_store_id }
      filters: {
        field: transactions.date_comparison_filter
        value: ""
      }
      filters: {
        field: transactions.is_customer
        value: "yes"
      }
    }
  }

  dimension: customer_id {
    type: number
    hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: customer_average_basket_size {
    type: number
    group_label: "Customer Lifetime"
    sql: ${TABLE}.customer_average_basket_size ;;
  }

  dimension: customer_lifetime_gross_margin {
    type: number
    group_label: "Customer Lifetime"
    sql: ${TABLE}.customer_lifetime_gross_margin ;;
  }

  dimension: customer_lifetime_sales {
    type: number
    group_label: "Customer Lifetime"
    sql: ${TABLE}.customer_lifetime_sales ;;
  }

  dimension: customer_lifetime_transactions {
    type: number
    group_label: "Customer Lifetime"
    sql: ${TABLE}.customer_lifetime_transactions ;;
  }

  dimension: customer_lifetime_quantity {
    type: number
    group_label: "Customer Lifetime"
    sql: ${TABLE}.customer_lifetime_quantity ;;
  }

  dimension_group: customer_first_purchase {
    type: time
    group_label: "Customer Lifetime"
    timeframes: [raw,date,week,month]
    sql: ${TABLE}.customer_first_purchase_date ;;
  }

  dimension_group: customer_tenure {
    type: duration
    sql_start: ${customer_first_purchase_raw} ;;
    sql_end: CURRENT_TIMESTAMP() ;;
    group_label: "Customer Lifetime"
    intervals: [day,week,month]
  }

  dimension: customer_spend_trend_past_year {
    type: number
    group_label: "Customer Lifetime"
    value_format_name: percent_1
    sql: ${TABLE}.customer_spend_trend_past_year ;;
  }

  dimension: customer_favorite_store_id {
    hidden: yes
    type: string
    sql: ${TABLE}.customer_favorite_store_id ;;
  }
}
