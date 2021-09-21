view: products {
  label: "Products 📦"
  sql_table_name: `@{SCHEMA_NAME}.@{PRODUCTS_TABLE_NAME}` ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
    hidden: yes
    sql: ${TABLE}.ID ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.BRAND ;;
    drill_fields: [name]
  }

  dimension: category {
    type: string
    sql: ${TABLE}.CATEGORY ;;
    drill_fields: [stores.name,brand]
    link: {
      label: "{{value}} Item Dynamics"
      icon_url: "https://i.imgur.com/W4tVGrj.png"
      url: "/dashboards/retail_block_model_v2::item_affinity_analysis?Focus%20Category={{value | encode_uri}}&Minimum%20Purchase%20Frequency="
    }
  }

  dimension: name {
    label: "Product Name"
    type: string
    sql: ${TABLE}.NAME ;;
    link: {
      label: "Drive attachments for {{rendered_value}}"
      icon_url: "https://i.imgur.com/W4tVGrj.png"
      url: "/dashboards/retail_block_model_v2::item_affinity_analysis?Focus%20Product={{value | encode_uri}}&Minimum%20Purchase%20Frequency="
    }
  }

  ##### DERIVED DIMENSIONS #####

  dimension: product_image {
    type: string
    sql: ${name} ;;
    html: <img src="@{IMAGE_SEARCH_URL}{{value | encode_uri }}" style="height: 50px; max-width: 150px;" /> ;;
  }

  ##### MEASURES #####

  measure: number_of_products {
    type: count_distinct
    sql: ${id} ;;
  }
}
