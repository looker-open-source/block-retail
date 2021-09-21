view: customers {
  label: "Customers 👥"
  sql_table_name: `@{SCHEMA_NAME}.@{CUSTOMERS_TABLE_NAME}` ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.ID ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}.address ;;
    group_label: "Address Info"
    link: {
      url: "/dashboards/retail_block_model_v2::address_deepdive?Address=%22{{value | encode_uri}}%22&Date%20Range={{ _filters['transactions.transaction_date']}}"
      label: "Drill into this address"
      icon_url: "https://img.icons8.com/cotton/2x/worldwide-location.png"
    }
  }

  dimension: country {
    type: string
    group_label: "Address Info"
    map_layer_name: countries
    sql: ${TABLE}.COUNTRY ;;
  }

  dimension_group: registered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.CREATED_AT ;;
  }

  dimension: latitude {
    hidden: yes
    type: number
    sql: ${TABLE}.LATITUDE ;;
  }

  dimension: longitude {
    hidden: yes
    type: number
    sql: ${TABLE}.LONGITUDE ;;
  }

  ##### CUSTOM DIMENSIONS #####

  dimension: location {
    type: location
    group_label: "Address Info"
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension: address_street_view {
    type: string
    group_label: "Address Info"
    sql: ${address} ;;
    html: <img src="https://maps.googleapis.com/maps/api/streetview?size=700x400&location={{value | encode_uri}}&fov=120&key=@{GOOGLE_MAPS_API_KEY}" ;;
  }

  filter: address_comparison_filter {
    type: string
    suggest_dimension: customers.address
  }

  dimension: address_comparison {
    type: string
    group_label: "Address Info"
    sql: CASE
      WHEN {% condition address_comparison_filter %} ${address} {% endcondition %} THEN ${address}
      ELSE 'vs Average'
    END;;
    order_by_field: address_comparison_order
  }

  dimension: address_comparison_order {
    hidden: yes
    type: number
    sql: CASE
      WHEN {% condition address_comparison_filter %} ${address} {% endcondition %} THEN 1
      ELSE 2
    END;;
  }
}
