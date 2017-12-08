view: bq_zcta_distances {
  derived_table: {
    sql: SELECT *
          FROM
        `looker-datablocks.acs_fast_facts.zcta_distances_*`
        WHERE
          zip1 = {% parameter zcta_distances.zip1 %}
          AND _TABLE_SUFFIX = SUBSTR( {% parameter zcta_distances.zip1 %}, 0, 1)
        UNION ALL
          SELECT
            {% parameter zcta_distances.zip1 %} as zip1,
            {% parameter zcta_distances.zip1 %} as zip2,
            0
          ;;
    }

    dimension: mi_to_zcta5 {
      label: "Miles from selected ZIP"
      view_label: "Geography"
      group_label: "ZIP Radii"
      type: number
      sql: ${TABLE}.mi_to_zcta5 ;;
      value_format_name: decimal_2
    }

    dimension: zip1 {
      label: "Selected ZIP Code"
      view_label: "Geography"
      group_label: "ZIP Radii"
      type: zipcode
      sql: ${TABLE}.zip1 ;;
      suggestable: no
    }

    dimension: zip2 {
      label: "Nearby ZIP"
      view_label: "Geography"
      group_label: "ZIP Radii"
      type: zipcode
      sql: ${TABLE}.zip2 ;;
      hidden: yes
    }
  }
