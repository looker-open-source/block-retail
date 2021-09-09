include: "//@{CONFIG_PROJECT_NAME}/views/base_channels.view"

view: channels {
  extends: [channels_config]
}

view: channels_core {
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
