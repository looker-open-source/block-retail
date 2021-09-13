include: "date_comparison.view.lkml"

view: transactions {
  sql_table_name: `@{SCHEMA_NAME}.@{TRANSACTIONS_TABLE_NAME}` ;;
  extends: [date_comparison]


  dimension: transaction_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.transaction_id ;;
  }

  dimension: channel_id {
    type: string
    hidden: yes
    sql: ${TABLE}.channel_id ;;
  }

  dimension: customer_id {
    type: string
    hidden: no
    sql: ${TABLE}.customer_id ;;
  }

  dimension: line_items {
    hidden: yes
    sql: ${TABLE}.line_items ;;
  }

  dimension: store_id {
    type: string
    hidden: yes
    sql: ${TABLE}.store_id ;;
  }

  dimension_group: transaction {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      week_of_year,
      month_num
    ]
    sql: ${TABLE}.transaction_timestamp ;;
  }

  ##### DERIVED DIMENSIONS #####

  extends: [date_comparison]

  set: drill_detail {
    fields: [transaction_date, stores.name, products.area, products.name, transactions__line_items.total_sales, number_of_transactions]
  }

  dimension_group: since_first_customer_transaction {
    type: duration
    intervals: [month]
    sql_start: ${customer_facts.customer_first_purchase_raw} ;;
    sql_end: ${transaction_raw} ;;
  }

  dimension: is_customer {
    label: "Is Real Customer"
    hidden: yes
    type: yesno
    sql: ${customer_id} IS NOT NULL ;;
    # sql: ${customer_id} IS NOT NULL AND ${customer_id} <> '' AND ${customer_id} <> '0' ;;
  }

  dimension: real_customer_id {
    hidden: yes
    type: string
    sql: CASE WHEN ${is_customer} THEN ${customer_id} ELSE NULL END ;;
  }

  ##### MEASURES #####

  measure: number_of_transactions {
    type: count_distinct
    sql: ${transactions.transaction_id} ;;
    value_format_name: unit_k
    drill_fields: [drill_detail*]
  }

  measure: number_of_customers {
    type: count_distinct
    sql: ${transactions.customer_id} ;;
    filters: [is_customer: "yes"]
    value_format_name: unit_k
    drill_fields: [drill_detail*]
  }

  measure: number_of_stores {
    view_label: "Stores 🏪"
    type: count_distinct
    sql: ${transactions.store_id} ;;
    value_format_name: decimal_0
    drill_fields: [drill_detail*]
  }

  measure: number_of_customer_transactions {
    hidden: yes
    type: count_distinct
    sql: ${transaction_id} ;;
    filters: {
      field: is_customer
      value: "yes"
    }
  }

  measure: percent_customer_transactions {
    type: number
    sql: ${number_of_customer_transactions}/NULLIF(${number_of_transactions},0) ;;
    value_format_name: percent_1
    drill_fields: [drill_detail*]
  }

  measure: first_transaction {
    type: date
    sql: MIN(${transaction_raw}) ;;
    drill_fields: [drill_detail*]
  }

  ##### DATE COMPARISON MEASURES #####

  measure: number_of_transactions_n {
    view_label: "Date Comparison 📅"
    label: "Number of Transactions N"
    type: count_distinct
    sql: CASE WHEN ${transactions.selected_comparison} LIKE 'This%' THEN ${transaction_id} ELSE NULL END;;
    value_format_name: unit_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: number_of_transactions_n1 {
    view_label: "Date Comparison 📅"
    label: "Number of Transactions N-1"
    type: count_distinct
    sql: CASE WHEN ${transactions.selected_comparison} LIKE 'Prior%' THEN ${transaction_id} ELSE NULL END;;
    value_format_name: unit_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: number_of_transactions_change {
    view_label: "Date Comparison 📅"
    label: "Number of Transactions Change (%)"
    type: number
    sql: ${number_of_transactions_n} / NULLIF(${number_of_transactions_n1},0) -1;;
    value_format_name: percent_1
    drill_fields: [drill_detail*]
  }

  measure: number_of_customers_n {
    view_label: "Date Comparison 📅"
    label: "Number of Customers N"
    type: count_distinct
    sql: CASE WHEN ${transactions.selected_comparison} LIKE 'This%' AND ${is_customer} THEN ${customer_id} ELSE NULL END;;
    value_format_name: unit_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: number_of_customers_n1 {
    view_label: "Date Comparison 📅"
    label: "Number of Customers N-1"
    type: count_distinct
    sql: CASE WHEN ${transactions.selected_comparison} LIKE 'Prior%' AND ${is_customer} THEN ${customer_id} ELSE NULL END;;
    value_format_name: unit_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: number_of_customers_change {
    view_label: "Date Comparison 📅"
    label: "Number of Customers Change (%)"
    type: number
    sql: ${number_of_customers_n} / NULLIF(${number_of_customers_n1},0) -1;;
    value_format_name: percent_1
    drill_fields: [drill_detail*]
  }

  ##### PER STORE MEASURES #####

  measure: number_of_transactions_per_store {
    view_label: "Stores 🏪"
    type: number
    sql: ${number_of_transactions}/NULLIF(${number_of_stores},0) ;;
    value_format_name: decimal_0
    drill_fields: [transactions.drill_detail*]
  }
}
