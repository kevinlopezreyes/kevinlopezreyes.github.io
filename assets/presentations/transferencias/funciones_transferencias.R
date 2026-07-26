# Funciones didácticas para la práctica de transferencias
# ---------------------------------------------------------
# Estas funciones simulan ambientes y especies virtuales. No representan
# un sistema biológico específico: permiten conocer la "verdad" que el
# modelo intenta recuperar.

make_env <- function(n = 90,
                     temp_shift = 0,
                     precip_shift = 0,
                     twist = 0) {
  template <- terra::rast(
    nrows = n,
    ncols = n,
    xmin = 0,
    xmax = 100,
    ymin = 0,
    ymax = 100,
    crs = "EPSG:3857"
  )

  xy <- terra::xyFromCell(template, seq_len(terra::ncell(template)))
  x <- scales::rescale(xy[, 1], to = c(-1, 1))
  y <- scales::rescale(xy[, 2], to = c(-1, 1))

  temp <- 0.85 * x + 0.35 * y +
    0.20 * sin(3 * y) +
    temp_shift / 100

  precip <- -0.30 * x + 0.90 * y +
    0.22 * cos(3 * x + twist * pi / 180) +
    precip_shift / 100

  env <- c(template, template)
  terra::values(env) <- cbind(temp, precip)
  names(env) <- c("temp", "precip")
  env
}

suitability_raster <- function(env,
                               opt = c(0.15, -0.10),
                               tol = c(0.65, 0.80),
                               name = "suitability") {
  temp <- env[["temp"]]
  precip <- env[["precip"]]

  suitability <- exp(
    -0.5 * (
      ((temp - opt[1]) / tol[1])^2 +
      ((precip - opt[2]) / tol[2])^2
    )
  )

  names(suitability) <- name
  suitability
}

sample_occ <- function(env,
                       n = 150,
                       opt = c(0.15, -0.10),
                       tol = c(0.65, 0.80),
                       accessible = c(0, 100, 0, 100),
                       bias_center = NULL,
                       bias_strength = 0,
                       seed = 1) {
  set.seed(seed)

  suitability <- suitability_raster(env, opt = opt, tol = tol)
  xy <- terra::xyFromCell(suitability, seq_len(terra::ncell(suitability)))
  weights <- terra::values(suitability, mat = FALSE)

  inside <- xy[, 1] >= accessible[1] &
    xy[, 1] <= accessible[2] &
    xy[, 2] >= accessible[3] &
    xy[, 2] <= accessible[4]

  weights[!inside] <- 0

  if (!is.null(bias_center) && bias_strength > 0) {
    distance <- sqrt(
      (xy[, 1] - bias_center[1])^2 +
      (xy[, 2] - bias_center[2])^2
    )
    sampling_bias <- exp(-bias_strength * distance / max(distance))
    weights <- weights * sampling_bias
  }

  selected <- sample(
    seq_len(nrow(xy)),
    size = n,
    replace = FALSE,
    prob = weights
  )

  tibble::tibble(
    longitude = xy[selected, 1],
    latitude = xy[selected, 2]
  )
}

make_background <- function(env, n = 5000, seed = 1) {
  set.seed(seed)
  points <- terra::spatSample(
    env[[1]],
    size = n,
    method = "random",
    as.points = TRUE,
    na.rm = TRUE
  )

  xy <- terra::crds(points)
  tibble::tibble(
    longitude = xy[, 1],
    latitude = xy[, 2]
  )
}

plot_env <- function(env, variable, title) {
  data <- as.data.frame(env[[variable]], xy = TRUE, na.rm = TRUE)

  ggplot2::ggplot(data, ggplot2::aes(x, y, fill = .data[[variable]])) +
    ggplot2::geom_raster() +
    ggplot2::coord_equal(expand = FALSE) +
    ggplot2::scale_fill_viridis_c(option = "C") +
    ggplot2::labs(title = title, x = NULL, y = NULL, fill = variable) +
    ggplot2::theme_void(base_size = 13) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      legend.position = "bottom"
    )
}

plot_suit <- function(raster, occurrences = NULL, title = NULL) {
  name <- names(raster)[1]
  data <- as.data.frame(raster[[1]], xy = TRUE, na.rm = TRUE)

  plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(x, y, fill = .data[[name]])
  ) +
    ggplot2::geom_raster() +
    ggplot2::coord_equal(expand = FALSE) +
    ggplot2::scale_fill_viridis_c(
      option = "mako",
      limits = c(0, 1)
    ) +
    ggplot2::labs(title = title, x = NULL, y = NULL, fill = "Idoneidad") +
    ggplot2::theme_void(base_size = 13) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      legend.position = "bottom"
    )

  if (!is.null(occurrences)) {
    plot <- plot +
      ggplot2::geom_point(
        data = occurrences,
        ggplot2::aes(longitude, latitude),
        inherit.aes = FALSE,
        size = 0.8,
        alpha = 0.65,
        color = "white"
      )
  }

  plot
}

extract_env <- function(env, points) {
  values <- terra::extract(
    env,
    points[, c("longitude", "latitude")],
    ID = FALSE
  )
  dplyr::bind_cols(points, values)
}

novelty_ranges <- function(reference_env, transfer_env) {
  reference <- terra::values(reference_env, na.rm = TRUE)
  lower <- apply(reference, 2, min, na.rm = TRUE)
  upper <- apply(reference, 2, max, na.rm = TRUE)

  transfer_values <- terra::values(transfer_env, mat = TRUE)
  outside <- sweep(transfer_values, 2, lower, FUN = "<") |
    sweep(transfer_values, 2, upper, FUN = ">")

  novelty <- transfer_env[[1]]
  terra::values(novelty) <- rowSums(outside, na.rm = TRUE)
  names(novelty) <- "variables_fuera_de_rango"
  novelty
}

clamp_env <- function(transfer_env, reference_env) {
  reference <- terra::values(reference_env, na.rm = TRUE)
  lower <- apply(reference, 2, min, na.rm = TRUE)
  upper <- apply(reference, 2, max, na.rm = TRUE)

  result <- transfer_env
  for (i in seq_len(terra::nlyr(result))) {
    result[[i]] <- terra::clamp(
      result[[i]],
      lower = lower[i],
      upper = upper[i],
      values = TRUE
    )
  }
  result
}
