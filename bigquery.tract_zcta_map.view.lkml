view: bq_tract_zcta_map {
  label: "Geography"
  derived_table: {
    sql:
      SELECT geoid, ZCTA5  FROM
      (select *,  ROW_NUMBER() OVER (PARTITION BY GEOID ORDER BY ZPOPPCT DESC) row_num
      from `looker-datablocks.acs_fast_facts.zcta_to_tract_w_state`)
      WHERE row_num = 1;;
    persist_for: "10000 hours"
  }
  view_label: "Geography"
  dimension: geoid11 {sql: ${TABLE}.geoid;; hidden:yes}
  dimension: ZCTA5 {
    sql: LPAD(CAST(${TABLE}.ZCTA5 as STRING), 5, '0');;
    type: zipcode
    label: "ZIP (ZCTA)"
  }
}

map_layer: block_group {
  format: "vector_tile_region"
  url: "https://a.tiles.mapbox.com/v4/dwmintz.4mqiv49l/{z}/{x}/{y}.mvt?access_token=pk.eyJ1IjoiZHdtaW50eiIsImEiOiJjajFoemQxejEwMHVtMzJwamw4OXprZWg0In0.qM9sl1WAxbEUMVukVGMazQ"
  feature_key: "us_block_groups_simple-c0qtbp"
  extents_json_url: "https://cdn.rawgit.com/dwmintz/census_extents2/59fa2cd8/bg_extents.json"
  min_zoom_level: 9
  max_zoom_level: 14
  property_key: "GEOID"
}

map_layer: tract {
  format: "vector_tile_region"
  url: "https://a.tiles.mapbox.com/v4/dwmintz.3zfb3asw/{z}/{x}/{y}.mvt?access_token=pk.eyJ1IjoiZHdtaW50eiIsImEiOiJjajFoemQxejEwMHVtMzJwamw4OXprZWg0In0.qM9sl1WAxbEUMVukVGMazQ"
  feature_key: "us_tracts-6w08eq"
  extents_json_url: "https://cdn.rawgit.com/dwmintz/census_extents2/396e32db/tract_extents.json"
  min_zoom_level: 6
  max_zoom_level: 12
  property_key: "GEOID"
}
