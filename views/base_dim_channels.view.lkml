view: channels {
  sql_table_name: `@{SCHEMA_NAME}.@{CHANNELS_TABLE_NAME}` ;;

  dimension: id {
    type: number
    hidden: yes
    sql: ${TABLE}.ID ;;
  }

  dimension: name {
    type: string
    label: "Channel Name"
    sql: ${TABLE}.NAME ;;
  }
}
