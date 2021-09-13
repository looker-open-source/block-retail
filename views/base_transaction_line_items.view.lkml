view: transactions__line_items {
  label: "Transactions"

  dimension: product_id {
    type: string
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: cost_of_goods_sold {
    type: number
    sql: ${TABLE}.cost_of_goods_sold ;;
  }

  ##### DERIVED DIMENSIONS #####

  dimension: gross_margin {
    type: number
    sql: ${sale_price} - ${cost_of_goods_sold} ;;
  }

  ##### MEASURES #####

  measure: total_sales {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: currency_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: total_gross_margin {
    type: sum
    sql: ${gross_margin} ;;
    value_format_name: currency_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: total_quantity {
    type: sum
    sql: ${quantity} ;;
    value_format_name: unit_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: average_basket_size {
    type: number
    sql: ${total_sales}/NULLIF(${transactions.number_of_transactions},0) ;;
    value_format_name: currency
    drill_fields: [transactions.drill_detail*]
  }

  measure: average_item_price {
    type: number
    sql: ${total_sales}/NULLIF(${total_quantity},0) ;;
    value_format_name: currency
    drill_fields: [transactions.drill_detail*]
  }

  ##### DATE COMPARISON MEASURES #####

  measure: sales_n {
    view_label: "Date Comparison 📅"
    label: "Sales N"
    type: sum
    sql: CASE WHEN ${transactions.selected_comparison} LIKE 'This%' THEN ${sale_price} ELSE NULL END;;
    value_format_name: currency_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: sales_n1 {
    view_label: "Date Comparison 📅"
    label: "Sales N-1"
    type: sum
    sql: CASE WHEN ${transactions.selected_comparison} LIKE 'Prior%' THEN ${sale_price} ELSE NULL END;;
    value_format_name: currency_k
    drill_fields: [transactions.drill_detail*]
  }

  measure: sales_change {
    view_label: "Date Comparison 📅"
    label: "Sales Change (%)"
    type: number
    sql: ${sales_n} / NULLIF(${sales_n1},0) -1;;
    value_format_name: percent_1
    drill_fields: [transactions.drill_detail*]
  }

  measure: sales_trend_past_year {
    view_label: "Date Comparison 📅"
    label: "Spend Trend in Past Year"
    type: number
    sql: SUM(CASE WHEN ${transactions.transaction_raw} >= TIMESTAMP(DATE_ADD(CURRENT_DATE(),INTERVAL -6 MONTH)) AND ${transactions.transaction_raw} < CURRENT_TIMESTAMP() THEN ${sale_price} ELSE NULL END)
      /NULLIF(SUM(CASE WHEN ${transactions.transaction_raw} >= TIMESTAMP(DATE_ADD(CURRENT_DATE(),INTERVAL -12 MONTH)) AND ${transactions.transaction_raw} < TIMESTAMP(DATE_ADD(CURRENT_DATE(),INTERVAL -6 MONTH)) THEN ${sale_price} ELSE NULL END),0) -1;;
    value_format_name: percent_1
    drill_fields: [transactions.drill_detail*]
  }

  ##### PER STORE MEASURES #####

  measure: total_sales_per_store {
    view_label: "Stores 🏪"
    type: number
    sql: ${total_sales}/NULLIF(${transactions.number_of_stores},0) ;;
    value_format_name: currency_0
    drill_fields: [transactions.drill_detail*]
  }

  measure: total_quantity_per_store {
    view_label: "Stores 🏪"
    type: number
    sql: ${total_quantity}/NULLIF(${transactions.number_of_stores},0) ;;
    value_format_name: decimal_0
    drill_fields: [transactions.drill_detail*]
  }

  ##### PER ADDRESS MEASURES #####

  measure: number_of_addresses {
    hidden: yes
    view_label: "Customers 👥"
    type: count_distinct
    sql: ${customers.address};;
    value_format_name: decimal_0
    drill_fields: [transactions.drill_detail*]
  }

  measure: number_of_customers_per_address {
    view_label: "Customers 👥"
    type: number
    sql: ${transactions.number_of_customers}/NULLIF(${number_of_addresses},0) ;;
    value_format_name: decimal_0
    drill_fields: [transactions.drill_detail*]
  }

  ##### PRODUCT AND TRANSACTION SEQUENCE MEASURES #####

  measure: main_category {
    hidden: yes
    type: string
    sql: STRING_AGG(${products.category}, ", " ORDER BY ${sale_price} desc LIMIT 1) ;;
  }

  measure: category_list {
    hidden: yes
    type: string
    sql: STRING_AGG(distinct ${products.category}, ", " ORDER BY ${products.category} asc) ;;
  }
}
