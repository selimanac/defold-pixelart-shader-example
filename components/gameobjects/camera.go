components {
  id: "orbit_camera"
  component: "/scripts/orbit_camera.script"
  properties {
    id: "target"
    value: ""
    type: PROPERTY_TYPE_HASH
  }
}
embedded_components {
  id: "camera"
  type: "camera"
  data: "aspect_ratio: 1.0\n"
  "fov: 0.7854\n"
  "near_z: -50.0\n"
  "far_z: 50.0\n"
  "auto_aspect_ratio: 1\n"
  "orthographic_projection: 1\n"
  "orthographic_zoom: 30.0\n"
  ""
}
