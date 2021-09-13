view: customer_transaction_sequence_base {
  derived_table: {
    explore_source: transactions {
      column: customer_id {}
      column: transaction_timestamp { field: transactions.transaction_raw }
      column: main_category { field: transactions__line_items.main_category}
      column: category_list { field: transactions__line_items.category_list}
      bind_filters: {
        from_field: transactions.date_comparison_filter
        to_field: transactions.date_comparison_filter
      }
      filters: {
        field: transactions.is_customer
        value: "yes"
      }
    }
  }
}

view: customer_transaction_sequence {
  label: "Customer Transaction Sequence ➡️"
  derived_table: {
    sql: SELECT customer_id, transaction_timestamp, category_list, transaction_sequence
        ,MIN(CASE WHEN transaction_sequence=1 THEN category_list ELSE NULL END) OVER (PARTITION BY customer_id) AS category_list_transaction_1
        ,MIN(CASE WHEN transaction_sequence=2 THEN category_list ELSE NULL END) OVER (PARTITION BY customer_id) AS category_list_transaction_2
        ,MIN(CASE WHEN transaction_sequence=3 THEN category_list ELSE NULL END) OVER (PARTITION BY customer_id) AS category_list_transaction_3
        ,MIN(CASE WHEN transaction_sequence=4 THEN category_list ELSE NULL END) OVER (PARTITION BY customer_id) AS category_list_transaction_4
        ,MIN(CASE WHEN transaction_sequence=5 THEN category_list ELSE NULL END) OVER (PARTITION BY customer_id) AS category_list_transaction_5
        ,MIN(CASE WHEN transaction_sequence=1 THEN main_category ELSE NULL END) OVER (PARTITION BY customer_id) AS main_category_transaction_1
        ,MIN(CASE WHEN transaction_sequence=2 THEN main_category ELSE NULL END) OVER (PARTITION BY customer_id) AS main_category_transaction_2
        ,MIN(CASE WHEN transaction_sequence=3 THEN main_category ELSE NULL END) OVER (PARTITION BY customer_id) AS main_category_transaction_3
        ,MIN(CASE WHEN transaction_sequence=4 THEN main_category ELSE NULL END) OVER (PARTITION BY customer_id) AS main_category_transaction_4
        ,MIN(CASE WHEN transaction_sequence=5 THEN main_category ELSE NULL END) OVER (PARTITION BY customer_id) AS main_category_transaction_5
       FROM
       (SELECT customer_id, transaction_timestamp, main_category, category_list
        , DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY transaction_timestamp ASC) AS transaction_sequence
        FROM
        ${customer_transaction_sequence_base.SQL_TABLE_NAME});;
  }

  dimension: customer_id {
    hidden: yes
    type: number
    sql: ${TABLE}.customer_id ;;
  }

  dimension_group: transaction {
    hidden: yes
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.transaction_timestamp ;;
  }

  dimension: category_list {
    type: string
    sql: ${TABLE}.category_list ;;
  }

  dimension: transaction_sequence {
    type: number
    sql: ${TABLE}.transaction_sequence ;;
  }

  dimension: product_category_list_transaction_1 {
    type: string
    sql: ${TABLE}.category_list_transaction_1 ;;
  }

  dimension: product_category_list_transaction_2 {
    type: string
    sql: ${TABLE}.category_list_transaction_2 ;;
  }

  dimension: product_category_list_transaction_3 {
    type: string
    sql: ${TABLE}.category_list_transaction_3 ;;
  }

  dimension: product_category_list_transaction_4 {
    type: string
    sql: ${TABLE}.category_list_transaction_4 ;;
  }

  dimension: product_category_list_transaction_5 {
    type: string
    sql: ${TABLE}.category_list_transaction_5 ;;
  }

  dimension: main_product_category_transaction_1 {
    type: string
    sql: ${TABLE}.main_category_transaction_1 ;;
  }

  dimension: main_product_category_transaction_2 {
    type: string
    sql: ${TABLE}.main_category_transaction_2 ;;
  }

  dimension: main_product_category_transaction_3 {
    type: string
    sql: ${TABLE}.main_category_transaction_3 ;;
  }

  dimension: main_product_category_transaction_4 {
    type: string
    sql: ${TABLE}.main_category_transaction_4 ;;
  }

  dimension: main_product_category_transaction_5 {
    type: string
    sql: ${TABLE}.main_category_transaction_5 ;;
  }
}
