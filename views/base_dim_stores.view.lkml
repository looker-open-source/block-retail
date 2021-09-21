view: stores {
  label: "Stores 🏪"
  sql_table_name: `@{SCHEMA_NAME}.@{STORES_TABLE_NAME}` ;;

  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.ID ;;
  }

  dimension: latitude {
    type: number
    hidden: yes
    sql: ${TABLE}.LATITUDE ;;

  }

  dimension: longitude {
    type: number
    hidden: yes
    sql: ${TABLE}.LONGITUDE ;;
  }

  dimension: name {
    drill_fields: [products.category]
    label: "Store Name"
    type: string
    sql: ${TABLE}.NAME ;;
    link: {
      url: "/dashboards/retail_block_model_v2::store_deepdive?Date={{ _filters['transactions.date_comparison_filter'] | url_encode }}&Store={{value | encode_uri}}"
      label: "Drill down into {{rendered_value}}"
    }
  }

  ##### DERIVED DIMENSIONS #####

  dimension: location {
    type: location
    group_label: "Store Info"
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  filter: store_for_comparison {
    type: string
    group_label: "Store Comparison"
    suggest_dimension: stores.name
  }

  dimension: store_comparison_vs_stores_in_tier {
    type: string
    group_label: "Store Comparison"
    sql: CASE
      WHEN {% condition store_for_comparison %} ${name} {% endcondition %} THEN CONCAT('1- ',${name})
      WHEN ${store_tiering.tier_id} = (SELECT tier_id FROM ${store_tiering.SQL_TABLE_NAME} WHERE {% condition store_for_comparison %} store_name {% endcondition %} LIMIT 1) THEN ${name}
      ELSE NULL
    END;;
  }

  dimension: store_comparison_vs_stores_in_tier_with_weather {
    type: string
    group_label: "Store Comparison"
    sql: CASE
      WHEN {% condition store_for_comparison %} ${name} {% endcondition %} THEN CONCAT('1- ',${name})
      WHEN ${store_tiering.tier_id} = (SELECT tier_id FROM ${store_tiering.SQL_TABLE_NAME} WHERE {% condition store_for_comparison %} store_name {% endcondition %} LIMIT 1) THEN ${name}
      ELSE NULL
    END;;
    html: {{rendered_value}}{% if store_weather.average_daily_precipitation._value < 2.0 %} - 🌞{% elsif store_weather.average_daily_precipitation._value < 4.0 %} - ☁️{% elsif store_weather.average_daily_precipitation._value > 4.0 %} - 🌧️️{% else %}{% endif %};;
  }

  dimension: store_comparison_vs_tier {
    type: string
    group_label: "Store Comparison"
    sql: CASE
      WHEN {% condition store_for_comparison %} ${name} {% endcondition %} THEN CONCAT('1- ',${name})
      WHEN ${store_tiering.tier_id} = (SELECT tier_id FROM ${store_tiering.SQL_TABLE_NAME} WHERE {% condition store_for_comparison %} store_name {% endcondition %} LIMIT 1) THEN  '2- Rest of Stores in Tier'
      ELSE NULL
    END;;
  }
}
