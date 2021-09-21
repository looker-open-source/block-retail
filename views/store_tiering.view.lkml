view: store_tiering_base {
  derived_table: {
    explore_source: transactions {
      column: id { field: stores.id }
      column: name { field: stores.name }
      column: total_sales { field: transactions__line_items.total_sales }
      filters: {
        field: transactions.date_comparison_filter
        value: "2 years"
      }
    }
  }
}

view: store_tiering {
  label: "Stores 🏪"
  derived_table: {
    datagroup_trigger: monthly
    sql: SELECT store_id, store_name, DIV(rn,20)+1 AS tier_id
    FROM
    (SELECT id as store_id, name as store_name, ROW_NUMBER() OVER (ORDER BY total_sales desc) as rn
    FROM ${store_tiering_base.SQL_TABLE_NAME})  ;;
  }

  dimension: store_id {hidden:yes}
  dimension: store_name {hidden:yes}
  dimension: tier_id {
    type: number
    sql: ${TABLE}.tier_id ;;
    label: "Store Tier"
  }
}
