view: bq_logrecno_bg_map {
  label: "Geography"
  derived_table: {
    sql:
      SELECT
        UPPER(stusab) as stusab,
        logrecno,
        CONCAT(UPPER(stusab), CAST(logrecno AS STRING)) as row_id,
        sumlevel,
        state as state_fips_code,
        county as county_fips_code,
        tract,
        blkgrp,
        SUBSTR(geo.geoid, 8, 11) as geoid11,
        geo.geoid,
        CASE
          WHEN sumlevel = '140'
          THEN REGEXP_EXTRACT(name, r'^[^,]*, [^,]*, ([^,]*)')
          WHEN sumlevel = '150'
          THEN REGEXP_EXTRACT(name, r'^[^,]*, [^,]*, [^,]*, ([^,]*)')
        END as state_name,
        CASE
          WHEN sumlevel = '140'
          THEN REGEXP_EXTRACT(name, r'^[^,]*, ([^,]*), [^,]*')
          WHEN sumlevel = '150'
          THEN REGEXP_EXTRACT(name, r'^[^,]*, [^,]*, ([^,]*), [^,]*')
        END as county_name,
        CASE
          WHEN sumlevel = '140'
          THEN REGEXP_EXTRACT(name, r'^([^,]*), [^,]*, [^,]*')
          WHEN sumlevel = '150'
          THEN REGEXP_EXTRACT(name, r'^[^,]*, ([^,]*), [^,]*, [^,]*')
        END as tract_name,
        CASE
          WHEN sumlevel = '150'
          THEN REGEXP_EXTRACT(name, r'^([^,]*), [^,]*, [^,]*, [^,]*')
        END as block_group_name,
        CASE WHEN geo.SUMLEVEL = '150' THEN bg.INTPTLAT END as latitude,
        CASE WHEN geo.SUMLEVEL = '150' THEN bg.INTPTLON END as longitude,
        SUM(COALESCE(bg.ALAND, tr.ALAND) * 0.000000386102159) AS square_miles_land,
        SUM(COALESCE(bg.AWATER, tr.AWATER) * .000000386102159) AS square_miles_water
      FROM
        `looker-datablocks.acs_fast_facts.geo_2015` as geo
      LEFT JOIN `looker-datablocks.acs_fast_facts.block_group_attribs` as bg on (SUBSTR(geo.GEOID, 8, 12) = bg.geoid AND geo.SUMLEVEL = '150')
      LEFT JOIN `looker-datablocks.acs_fast_facts.block_group_attribs` as tr on (SUBSTR(geo.GEOID, 8, 11) = SUBSTR(tr.geoid, 1, 11) AND geo.SUMLEVEL = '140')
      WHERE
        sumlevel in ('140', '150')
      GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ;;
    persist_for: "10000 hours"
  }
  dimension: row_id {sql: ${TABLE}.row_id;;
    primary_key:yes
    hidden: yes
  }
  dimension: geoid11 {hidden:yes}
  dimension: logrecno  {hidden:yes}
  dimension: blkgrp {hidden:yes}
  dimension: sumlevel {hidden:yes sql: ${TABLE}.sumlevel;;}

  # State

  dimension: stusab {
    label: "State Abbreviation"
    group_label: "State"
    link: {
      url: "https://maps.google.com?q={{value}}"
      label: "Google Maps"
    }
    suggest_persist_for: "120 hours"
  }

  dimension: state_name {
    group_label: "State"
    map_layer_name: us_states
    sql: ${TABLE}.state_name;;
    link: {
      url: "https://maps.google.com?q={{value}}"
      label: "Google Maps"
    }
    suggest_persist_for: "120 hours"
    drill_fields: [county, tract]
  }

  dimension: state {
    group_label: "State"
    label: "State FIPS Code"
    sql: ${TABLE}.state_fips_code;;
    suggest_persist_for: "120 hours"
  }

#   measure: count_state {
#     type:  count_distinct
#     sql: ${state_name} ;;
#     drill_fields: [state_name, data.default_drills*, count_county, count_tract, count_block]
#   }

  # County

  dimension: county {
    group_label: "County"
    label: "County FIPS Code"
    sql: CONCAT(${state}, ${TABLE}.county_fips_code);;
    map_layer_name: us_counties_fips
    drill_fields: [tract, block_group]
    suggest_persist_for: "120 hours"
  }

  dimension: county_name {
    group_label: "County"
    sql: CONCAT(${TABLE}.county_name, ', ', ${state_name});;
    link: {
      url: "https://maps.google.com?q={{value}}"
      label: "Google Maps"
    }
    suggest_persist_for: "120 hours"
  }

#   measure: count_county {
#     type:  count_distinct
#     sql: ${county_name} ;;
#     drill_fields: [county_name,  data.default_drills*,  count_tract, count_block,]
#   }

  # Tract

  dimension: tract {
    label: "Tract Geo Code"
    group_label: "Tract"
    sql: ${TABLE}.geoid11 ;;
    map_layer_name: tract
    suggest_persist_for: "120 hours"
  }

  dimension: tract_name {
    sql: CONCAT(${TABLE}.tract_name, ', ', ${county_name});;
    group_label: "Tract"
    link: {
      url: "https://google.com?q={{value}}"
      label: "Google"
    }
    suggest_persist_for: "120 hours"
  }

#   measure: count_tract {
#     type:  count_distinct
#     sql: ${tract_name} ;;
#     drill_fields: [tract_name, data.default_drills*,  count_block]
#   }

  # Block Group

  dimension: block_group {
    sql: SUBSTR(${TABLE}.geoid, 8, 12);;
    group_label: "Block Group"
    label: "Block Group Geo Code"
    map_layer_name: block_group
    link: {
      url: "https://google.com?q={{value}}"
      label: "Google"
    }
    suggest_persist_for: "120 hours"
  }

  dimension: block_group_name {
    sql: CONCAT(${TABLE}.block_group_name, ', ', ${tract_name}) ;;
    group_label: "Block Group"
    suggest_persist_for: "120 hours"
  }

  dimension: block_group_centroid {
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
    group_label: "Block Group"
    suggest_persist_for: "120 hours"
  }

  measure: sq_miles_land {
    sql: ${TABLE}.square_miles_land ;;
    label: "Square Miles of Land"
    type: sum
    value_format_name: decimal_2
  }

  measure: sq_miles_water {
    sql: ${TABLE}.square_miles_water ;;
    label: "Square Miles of Water"
    type: sum
    value_format_name: decimal_2
  }

#   measure: count_block {
#     type:  count_distinct
#     sql: ${block_group} ;;
#     drill_fields: [tract_name, data.default_drills*]
#   }


#   set: geo_drills {
#     fields: [count_state, count_county, count_tract, block_group]
#   }
}
